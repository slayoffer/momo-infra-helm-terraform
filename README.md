# momo-infra

Для работы требуется yc, git, terraform и helm

## Установка yc

[See Doc](https://cloud.yandex.ru/docs/cli/quickstart#install)

## Установка Git

[See Doc](https://git-scm.com/book/ru/v2/Введение-Установка-Git)

## Установка terraform

[See Doc](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

## Подключим yc к нашему кластеру

`yc init`

Во время инициализации можно записать folderId и clusterId(cloudId) они потребуются позже.

## Для авторизации провайдера терраформ потребуется сервисный аккаунт
Его можно создать в веб интерфейсе с ролью admin либо через yc

```console
yc iam service-account create --name terraformadmin --folder-id <FOLDER_ID>
...
id: <SERVICE_ACCOUNT_ID>

yc resource-manager folder add-access-binding --role admin --subject serviceAccount:<SERVICE_ACCOUNT_ID> <FOLDER_ID>
...

yc iam key create --service-account-id <SERVICE_ACCOUNT_ID> --output admin-sa-key.json
...
```

## Далее необходимо заполнить файл terraform.tfvars нашими переменными
В папке terraform/prepare содержится модуль не вызываемый из основного. В нём содержится код для создания s3 бакета
в котором основной модуль будет хранить своё состояние, а также статического IP адреса, который в последствии будет
использоваться для баллансировщика, у этого модуля, так как с основным он не связан, переменные необходимо так же заполнить вручную
и запустить этот модуль перед выполнением основного. В модуле есть Readme с описанием.

```console
cd terraform/prepare
mv terraform.tfvars.example terraform.tfvars # Заполнить переменные
terraform init
terraform apply
```

Как только мы получили внешний IP адрес - лучше сразу прописать A запись в DNS регистратора на сам домен и все поддомены (если требуется)
ссылающуюся на этот адрес

## После этого рекомендуется экспортировать полученные переменные из этого модуля, что описано в его readme

```console
export AWS_ACCESS_KEY_ID=$(terraform output -raw bucket_service_account_access_key) &&
export AWS_SECRET_ACCESS_KEY=$(terraform output -raw bucket_service_account_secret_key) &&
export MOMO_EXTERNAL_IP=$(terraform output -raw external_address)
```

## Далее можно переходить к инициализации основного модуля, который подключится к s3 с помощью данных которые мы только что экспортировали

```console
cd ..
mv terraform.tfvars.example terraform.tfvars # Заполнить переменные
terraform init
terraform apply
```

## Когда кластер и все необходимые ресурсы создадутся можно приступать к установке helm чартов в кластер
Нам понадобится переменная SUBNET_ID так что лучше сразу её экспортировать, находясь в папке с основным терраформом

`export SUBNET_ID=$(terraform output -raw subnet_id)`

## Так же нам понадобится конфиг докерфайла в base64 для того, чтобы кубер мог грузить из него образы
Если вы ещё не авторизовались в вашем докер репозитории нужно сделать сначала

`docker login <your-repo>`

## Затем созданный докером конфиг закодировать в base 64 и экспортировать

`export DOCKERCONFIGJSON=$(base64 -w 0 ~/.docker/config.json)`

## Добавление настроек подключения к кластеру в kubeconfig
k8s-cluster - имя кластера по умолчанию, если указали своё - необходимо поменять.
если кластер создавался несколько раз и на машине с которой производится развёртывание есть конфиг с таким же именем
кластера - поможет ключ --force

`yc managed-kubernetes cluster get-credentials k8s-cluster --external`

## Установка ALB ingress controller

[See Doc](https://cloud.yandex.ru/docs/managed-kubernetes/operations/applications/alb-ingress-controller)

## Рекомендуется создать отдельную папку в которой будет создан ключ и распакован хелм чарт

```console
mkdir alb-ingress
cd alb-ingress
```

## Шаблон команды создания ключа
```console
yc iam key create \
  --service-account-name <имя сервисного аккаунта для Ingress-контроллера> \
  --output sa-key.json
```
## Создание ключа с именем аккаунта по умолчанию
`yc iam key create --service-account-name k8s-alb-ingress --output sa-key.json`

# Установка jq, если он ещё не установлен
`sudo apt update && sudo apt install jq`

## Установка ALB ingress controller из helm чарта, актуальная на данный момент версия v0.1.16
```console
export HELM_EXPERIMENTAL_OCI=1 && \
cat sa-key.json | helm registry login cr.yandex --username 'json_key' --password-stdin && \
helm pull oci://cr.yandex/yc-marketplace/yandex-cloud/yc-alb-ingress/yc-alb-ingress-controller-chart \
  --version <версия Helm-чарта> \
  --untar && \
helm install \
  --namespace alb-ingress \
  --create-namespace \
  --set folderId=<идентификатор каталога> \
  --set clusterId=<идентификатор кластера> \
  --set-file saKeySecretKey=sa-key.json \
  yc-alb-ingress-controller ./yc-alb-ingress-controller-chart/
```
## Нам потребуется SSL сертификат для нашего домена, выпустить его можно различными способами
Так как мы работаем с ALB ингресс контроллером - сертификат должен быть либо выпущен средствами YC либо добавлен в облачное хранилище.

[See Doc](https://cloud.yandex.ru/docs/certificate-manager/operations/managed/cert-create)

## Экспортируем ID полученного сертификата

`export CERT_ID=<ID сертификата>`

## Установка чарта пельменной. Переходим в директорию helm
```console
helm upgrade --install \
--set global.dockerconfigjson=$DOCKERCONFIGJSON \
--set frontend.externalAddr=$MOMO_EXTERNAL_IP \
--set frontend.subnetId=$SUBNET_ID \
--set frontend.certId=$CERT_ID \
momo-store momo-chart
```
## Установка чарта мониторинга. При первом запуске потребуется обновление зависимостей, о чём helm подскажет сам.
```console
helm upgrade --install \
--set grafana.externalAddr=$MOMO_EXTERNAL_IP \
--set grafana.subnetId=$SUBNET_ID \
--set grafana.certId=$CERT_ID \
monitoring monitoring
```
Не забудьте при первом развертывании мониторинга зайти в графану и задать пароль, стандартный admin admin

## Для соединения GitLab с кластером потребуется установка агента
Подключается он в Гитлабе в разделе инфраструктура
Перед подключением необходимо создать конфигурационный файл в репозитории по следующему пути
.gitlab/agents/<agent-name>/config.yaml
в основном репозитории он уже есть
Это требуется для деплоя через kubectl или helm из пайплайна гитлаба
Подробности установки в документации
[See Doc](https://gitlab.praktikum-services.ru/help/user/clusters/agent/index)
