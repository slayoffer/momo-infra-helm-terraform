resource "yandex_iam_service_account" "k8s-sa" {
  name        = "k8s-sa"
  description = "K8S zonal service account"
}

resource "yandex_iam_service_account" "k8s-alb-ingress" {
  name        = "k8s-alb-ingress"
  description = "K8S ingress service account"
}

resource "yandex_resourcemanager_folder_iam_member" "k8s-clusters-agent" {
  # Сервисному аккаунту назначается роль "k8s.clusters.agent".
    
  provisioner "local-exec" {
    command = "sleep 30"
  }
  
  folder_id = var.folder_id
  role      = "k8s.clusters.agent"
  member    = "serviceAccount:${yandex_iam_service_account.k8s-sa.id}"
  depends_on = [
    yandex_iam_service_account.k8s-sa
  ]
}

resource "yandex_resourcemanager_folder_iam_member" "vpc-public-admin" {
  # Сервисному аккаунту назначается роль "vpc.publicAdmin".
    
  provisioner "local-exec" {
    command = "sleep 30"
  }
  
  folder_id = var.folder_id
  role      = "vpc.publicAdmin"
  member = "serviceAccount:${yandex_iam_service_account.k8s-sa.id}"
  depends_on = [
    yandex_iam_service_account.k8s-sa
  ]
}

resource "yandex_resourcemanager_folder_iam_member" "images-puller" {
  # Сервисному аккаунту назначается роль "container-registry.images.puller".
    
  provisioner "local-exec" {
    command = "sleep 30"
  }
  
  folder_id = var.folder_id
  role      = "container-registry.images.puller"
  member = "serviceAccount:${yandex_iam_service_account.k8s-sa.id}"
  depends_on = [
    yandex_iam_service_account.k8s-sa
  ]
}

resource "yandex_resourcemanager_folder_iam_member" "editor" {
  # Сервисному аккаунту назначается роль "alb.editor".
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.k8s-alb-ingress.id}"
  depends_on = [
    yandex_iam_service_account.k8s-alb-ingress
  ]
}

resource "yandex_resourcemanager_folder_iam_member" "certificates-downloader" {
  # Сервисному аккаунту назначается роль "certificate-manager.certificates.downloader".
  folder_id = var.folder_id
  role      = "certificate-manager.certificates.downloader"
  member    = "serviceAccount:${yandex_iam_service_account.k8s-alb-ingress.id}"
  depends_on = [
    yandex_iam_service_account.k8s-alb-ingress
  ]
}

resource "yandex_kms_symmetric_key" "kms-key" {
  # Ключ для шифрования важной информации, такой как пароли, OAuth-токены и SSH-ключи.
  name              = "kms-key"
  default_algorithm = "AES_128"
  rotation_period   = "8760h" # 1 год.
}

resource "yandex_kms_symmetric_key_iam_binding" "viewer" {
    
  provisioner "local-exec" {
    command = "sleep 30"
  }
  
  symmetric_key_id = yandex_kms_symmetric_key.kms-key.id
  role             = "viewer"
  members = ["serviceAccount:${yandex_iam_service_account.k8s-sa.id}"]
  depends_on = [
    yandex_kms_symmetric_key.kms-key,
    yandex_iam_service_account.k8s-sa
  ]
}

# resource "null_resource" "delay" {

#   provisioner "local-exec" {
#     command = "sleep 30"
#   }

#   depends_on = [
#     yandex_resourcemanager_folder_iam_member.k8s-clusters-agent,
#     yandex_resourcemanager_folder_iam_member.vpc-public-admin,
#     yandex_resourcemanager_folder_iam_member.images-puller,
#     yandex_kms_symmetric_key_iam_binding.viewer,
#     yandex_vpc_subnet.k8s-subnet-1,
#     yandex_kms_symmetric_key.kms-key,
#     yandex_vpc_security_group.k8s-main-sg,
#     yandex_vpc_security_group.k8s-master-whitelist
#   ]
# }

# resource "time_sleep" "wait_for_role_binding" {
#   create_duration = "30s"

#   depends_on = [
#     yandex_resourcemanager_folder_iam_member.k8s-clusters-agent,
#     yandex_resourcemanager_folder_iam_member.vpc-public-admin,
#     yandex_resourcemanager_folder_iam_member.images-puller,
#     yandex_kms_symmetric_key_iam_binding.viewer,
#     yandex_vpc_subnet.k8s-subnet-1,
#     yandex_kms_symmetric_key.kms-key,
#     yandex_vpc_security_group.k8s-main-sg,
#     yandex_vpc_security_group.k8s-master-whitelist
#   ]
# }