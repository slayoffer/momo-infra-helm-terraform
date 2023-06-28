# variable "token" {
#   description = "Yandex Cloud IAM token aka YC_TOKEN"
#   type        = string
# }

variable "key_file" {
  description = "Path to authorized_key.json"
  type        = string
}

variable "cloud_id" {
  description = "Yandex cloud_id"
  type        = string
  default     = "b1g163o72t4tv917hd0c"
}

variable "folder_id" {
  description = "Yandex folder_id"
  type        = string
  default     = "b1g154q9ujeuosljjnp2"
}

variable "zone" {
  description = "Yandex zone"
  type        = string
  default     = "ru-central1-a"
}

variable "whitelist" {
  description = "List of IP addresses for kubeconfig and ssh access"
  type = list(string)
}