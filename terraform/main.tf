locals {
  k8s_version = "1.23"
}

resource "yandex_kubernetes_cluster" "k8s-zonal" {
  
  network_id = yandex_vpc_network.k8s-network.id
  name = "k8s-cluster"
  cluster_ipv4_range = "10.96.0.0/16"
  service_ipv4_range = "10.112.0.0/16"
  master {
    public_ip = true
    version = local.k8s_version
    zonal {
      zone      = yandex_vpc_subnet.k8s-subnet-1.zone
      subnet_id = yandex_vpc_subnet.k8s-subnet-1.id
    }
    security_group_ids = [
      yandex_vpc_security_group.k8s-main-sg.id,
      yandex_vpc_security_group.k8s-master-whitelist.id
    ]
  }
  service_account_id      = yandex_iam_service_account.k8s-sa.id
  node_service_account_id = yandex_iam_service_account.k8s-sa.id
  kms_provider {
    key_id = yandex_kms_symmetric_key.kms-key.id
  }
  depends_on = [
    yandex_resourcemanager_folder_iam_member.k8s-clusters-agent,
    yandex_resourcemanager_folder_iam_member.vpc-public-admin,
    yandex_resourcemanager_folder_iam_member.images-puller,
    yandex_kms_symmetric_key_iam_binding.viewer,
    yandex_vpc_subnet.k8s-subnet-1,
    yandex_kms_symmetric_key.kms-key,
    yandex_vpc_security_group.k8s-main-sg,
    yandex_vpc_security_group.k8s-master-whitelist
  ]
}

resource "yandex_kubernetes_node_group" "worker-nodes" {
  cluster_id = yandex_kubernetes_cluster.k8s-zonal.id
  name       = "worker-nodes"
  version    = local.k8s_version
  instance_template {
    platform_id = "standard-v3"
    network_interface {
      nat                = true
      subnet_ids         = [yandex_vpc_subnet.k8s-subnet-1.id]
      security_group_ids = [
        yandex_vpc_security_group.k8s-main-sg.id,
        yandex_vpc_security_group.k8s-nodes-ssh-access.id,
        yandex_vpc_security_group.k8s-public-services.id
      ]
    }
    
    resources {
      memory = 4
      cores  = 2
    }
    
    boot_disk {
      type = "network-hdd"
      size = 30
    }

    scheduling_policy {
      preemptible = true
    }

    container_runtime {
      type = "containerd"
    }
  }
  scale_policy {
    auto_scale {
      min     = 1
      max     = 3
      initial = 1
    }
  }
  depends_on = [
    yandex_kubernetes_cluster.k8s-zonal
  ]
}

resource "yandex_vpc_network" "k8s-network" {
  name = "k8s-network"
}

resource "yandex_vpc_subnet" "k8s-subnet-1" {
  name           = "k8s-subnet-1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.k8s-network.id
  v4_cidr_blocks = ["10.1.0.0/16"]
  depends_on = [
    yandex_vpc_network.k8s-network,
  ]
}

output "subnet_id" {
  value = yandex_vpc_subnet.k8s-subnet-1.id
}