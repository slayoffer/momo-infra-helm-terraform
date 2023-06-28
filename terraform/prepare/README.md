Этот этап работает независимо от основного модуля, так как создаёт Bucket, который требуется основной конфигурации для хранения состояния в s3
А так же статический IP который в последствии используется баллансировщиком

Для запуска необходимо задать необходимые переменные, они описаны в variables.tf, а так же приложен пример их передачи через terraform.tfvars
переименуйте terraform.tfvars.example в terraform.tfvars и заполните
Для авторизации используется либо токен либо service_account_key_file, эти параметры не могут быть использованы одновременно,
поэтому неиспользуемый метод авторизации необходимо закомментировать или удалить из main.tf
Нужно экспортировать ключи доступа от нового сервисного аккаунта для использования s3 backend в основном модуле
Для этого после выполнения модуля нужно выполнить в терминале команды и в versions.tf основного модуля вручную указать имя созданного Bucket-a

```console
export AWS_ACCESS_KEY_ID=$(terraform output -raw bucket_service_account_access_key) &&
export AWS_SECRET_ACCESS_KEY=$(terraform output -raw bucket_service_account_secret_key) &&
export MOMO_EXTERNAL_IP=$(terraform output -raw external_address)
```
