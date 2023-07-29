locals {
  node_settings = {
    cores = 4
    sockets = 1
    memory = 8192

    storage_type = "scsi"
    storage_id = "ceph_disks"
    disk_size = "32G"
  }
}

module "k3s" {
  source = "./k3s"

  proxmox_node = "enterprise"
  node_template = "ubuntu-2204-cloudinit-template"

  network_gateway = "192.168.1.1"
  lan_subnet = "192.168.1.0/24"

  support_node_settings = local.node_settings

  master_nodes_count = 2
  master_node_settings = local.node_settings

  control_plane_subnet = "192.168.1.24/29"

  node_pools = [
    {
      name = "default"
      size = 2
      subnet = "192.168.1.32/28"
    }
  ]

  authorized_keys_file = "authorized_keys"
}

output "kubeconfig" {
  value = module.k3s.k3s_kubeconfig
  sensitive = true
}
