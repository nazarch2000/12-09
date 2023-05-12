terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  token = "***"
  cloud_id = "***"
  folder_id = "***"
  zone = "ru-central1-b"
}

resource "yandex_mdb_postgresql_cluster" "foo" {
  name        = "ha"
  environment = "PRESTABLE"
  network_id  = yandex_vpc_network.foo.id

  config {
    version = 15
    resources {
      resource_preset_id = "s2.micro"
      disk_type_id       = "network-ssd"
      disk_size          = 16
    }
  }

  maintenance_window {
    type = "ANYTIME"
  }

  host {
    zone             = "ru-central1-a"
    subnet_id        = yandex_vpc_subnet.foo.id
    assign_public_ip = true
  }

  host {
    zone             = "ru-central1-b"
    subnet_id        = yandex_vpc_subnet.bar.id
    assign_public_ip = true
  }
}

resource "yandex_vpc_subnet" "foo" {
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.foo.id
  v4_cidr_blocks = ["10.1.0.0/24"]
}

resource "yandex_vpc_subnet" "bar" {
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.foo.id
  v4_cidr_blocks = ["10.2.0.0/24"]
}

resource "yandex_mdb_postgresql_database" "db1" {
  cluster_id = "c9qbbperjn1329vr8un5"
  name       = "db1"
  owner      = "nazar"
  depends_on = [
    yandex_mdb_postgresql_user.nazar
  ]
}

resource "yandex_mdb_postgresql_user" "nazar" {
  cluster_id = "c9qbbperjn1329vr8un5"
  name       = "nazar"
  password   = "***"
}
