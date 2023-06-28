resource "yandex_iam_service_account" "image-bucket-sa" {
  name = "image-bucket-sa"
}

// Назначение роли сервисному аккаунту
resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = var.folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.image-bucket-sa.id}"
  depends_on = [
    yandex_iam_service_account.image-bucket-sa
  ]
}

// Создание статического ключа доступа
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.image-bucket-sa.id
  description        = "static access key for images object storage"
  depends_on = [
    yandex_iam_service_account.image-bucket-sa
  ]
}

// Создание бакета с использованием ключа
resource "yandex_storage_bucket" "images-bucket" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = "momo-shubin-11-images"
  acl        = "public-read"
  depends_on = [
    yandex_iam_service_account_static_access_key.sa-static-key
  ]
}

resource "yandex_storage_object" "id-1-9" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = "momo-shubin-11-images"
  key        = "8dee5a92281746aa887d6f19cf9fdcc7.jpg"
  source     = "./images/8dee5a92281746aa887d6f19cf9fdcc7.jpg"
  content_type = "image/jpeg"
  depends_on = [
    yandex_storage_bucket.images-bucket
  ]
}

resource "yandex_storage_object" "id-2-10" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = "momo-shubin-11-images"
  key        = "50b583271fa0409fb3d8ffc5872e99bb.jpg"
  source     = "./images/50b583271fa0409fb3d8ffc5872e99bb.jpg"
  content_type = "image/jpeg"
  depends_on = [
    yandex_storage_bucket.images-bucket
  ]
}

resource "yandex_storage_object" "id-3-11" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = "momo-shubin-11-images"
  key        = "8b50f76f514a4ccaaacdcb832a1b3a2f.jpg"
  source     = "./images/8b50f76f514a4ccaaacdcb832a1b3a2f.jpg"
  content_type = "image/jpeg"
  depends_on = [
    yandex_storage_bucket.images-bucket
  ]
}

resource "yandex_storage_object" "id-4-12" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = "momo-shubin-11-images"
  key        = "788c073d83c14b3fa00675306dfb32b5.jpg"
  source     = "./images/788c073d83c14b3fa00675306dfb32b5.jpg"
  content_type = "image/jpeg"
  depends_on = [
    yandex_storage_bucket.images-bucket
  ]
}

resource "yandex_storage_object" "id-5" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = "momo-shubin-11-images"
  key        = "32cc88a33c3243a6a8838c034878c564.jpg"
  source     = "./images/32cc88a33c3243a6a8838c034878c564.jpg"
  content_type = "image/jpeg"
  depends_on = [
    yandex_storage_bucket.images-bucket
  ]
}

resource "yandex_storage_object" "id-6-13" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = "momo-shubin-11-images"
  key        = "7685ad7e9e634a58a4c29120ac5a5ee1.jpg"
  source     = "./images/7685ad7e9e634a58a4c29120ac5a5ee1.jpg"
  content_type = "image/jpeg"
  depends_on = [
    yandex_storage_bucket.images-bucket
  ]
}

resource "yandex_storage_object" "id-7-14" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = "momo-shubin-11-images"
  key        = "4bdaeab0ee1842dc888d87d4a435afdd.jpg"
  source     = "./images/4bdaeab0ee1842dc888d87d4a435afdd.jpg"
  content_type = "image/jpeg"
  depends_on = [
    yandex_storage_bucket.images-bucket
  ]
}

resource "yandex_storage_object" "id-8" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = "momo-shubin-11-images"
  key        = "f64dcea998e34278a0006e0a2b104710.jpg"
  source     = "./images/f64dcea998e34278a0006e0a2b104710.jpg"
  content_type = "image/jpeg"
  depends_on = [
    yandex_storage_bucket.images-bucket
  ]
}





