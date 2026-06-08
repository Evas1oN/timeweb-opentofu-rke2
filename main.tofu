terraform {
  required_providers {
    twc = {
      source = "tf.timeweb.cloud/timeweb-cloud/timeweb-cloud"
    }
  }
  required_version = ">= 0.13"
}

provider "twc" {
  token = var.timeweb_token
}

resource "twc_ssh_key" "devops" {
  name = "devops"
  body = file("~/.ssh/id_rsa.pub")
}

data "twc_configurator" "basic" {
  location = "ru-3"
}

resource "twc_vpc" "vpc" {
  name = "vpc"
  subnet_v4 = "10.0.0.0/25"
  location = data.twc_configurator.basic.location
}

data "twc_os" "debian" {
  name = "debian"
  version = "13"
}

data "twc_os" "fedora" {
  name = "fedora"
  version = "44"
}

resource "twc_floating_ip" "haproxy-ip" {
  availability_zone = var.availability_zone
  ddos_guard = false
}

resource "twc_server" "haproxy" {
  name = "haproxy"
  hostname = "srv-prod-hpx01"
  os_id = data.twc_os.debian.id

  availability_zone = twc_floating_ip.haproxy-ip.availability_zone

  configuration {
    configurator_id = data.twc_configurator.basic.id
    disk = 15 * 1024
    ram = 1 * 1024
    cpu = 1
  }

  local_network {
    id = twc_vpc.vpc.id
  }

  floating_ip_id = twc_floating_ip.haproxy-ip.id
  ssh_keys_ids = [ twc_ssh_key.devops.id ]
}

resource "twc_server" "rke2-master-node" {
  count = 1
  hostname = "rke2-master-node${count.index + 1}"
  name = "rke2-master-node${count.index + 1}"
  os_id = data.twc_os.debian.id
  configuration {
    configurator_id = data.twc_configurator.basic.id
    disk = 20 * 1024
    ram = 4 * 1024
    cpu = 2
  }

  cloud_init = <<-EOT
#!/bin/sh
ip route add default via ${cidrhost(twc_vpc.vpc.subnet_v4, 1)} dev eth1
EOT

  local_network {
    id = twc_vpc.vpc.id
  }

  ssh_keys_ids = [ twc_ssh_key.devops.id ]
}