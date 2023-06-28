variable "token" {
  description = "Yandex Cloud IAM token aka YC_TOKEN"
  type        = string
}

variable "key_file" {
  description = "Path to authorized_key.json"
  type        = string
}

variable "cloud_id" {
  description = "Yandex cloud_id"
  type        = string
}

variable "folder_id" {
  description = "Yandex folder_id"
  type        = string
}

variable "zone" {
  description = "Yandex zone"
  type        = string
  default     = "ru-central1-a"
}

variable "bucket_name" {
  description = "Name of creating bucket"
  type        = string
  default     = "terraform-shubin-momo-bucket"
}