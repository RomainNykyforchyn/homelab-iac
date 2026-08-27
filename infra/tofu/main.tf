resource "proxmox_download_file" "ubuntu_cloud_image" {
  content_type = "import"
  datastore_id = var.image_datastore
  node_name    = var.node_name

  url       = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
  file_name = "ubuntu-24.04-noble-cloudimg-amd64.qcow2"

  # Keep applies deterministic. Update intentionally rather than silently
  # replacing the base image when Canonical refreshes "current".
  overwrite = false
}

resource "proxmox_virtual_environment_vm" "games" {
  name      = var.games_vm_name
  node_name = var.node_name
  vm_id     = var.games_vm_id

  description = "Games VM managed by OpenTofu"
  tags        = ["games", "iac"]

  started = true
  on_boot = true

  # Single-node homelab: host CPU gives the VM the best game-server CPU feature set.
  cpu {
    cores = var.games_vm_cores
    type  = "host"
  }
  agent {
    enabled = true
  }

  memory {
    dedicated = var.games_vm_memory_mb
  }

  scsi_hardware = "virtio-scsi-single"

  disk {
    datastore_id = var.vm_datastore
    import_from  = proxmox_download_file.ubuntu_cloud_image.id
    interface    = "scsi0"
    iothread     = true
    discard      = "on"
    ssd          = true
    size         = var.games_vm_disk_gb
  }

  initialization {
    datastore_id = var.vm_datastore

    dns {
      servers = var.dns_servers
    }

    ip_config {
      ipv4 {
        address = var.games_vm_ip_cidr
        gateway = var.games_vm_gateway
      }
    }

    user_account {
      username = var.vm_username
      keys     = [trimspace(file(pathexpand(var.ssh_public_key_path)))]
    }
  }

  network_device {
    bridge   = var.bridge
    model    = "virtio"
    firewall = true
  }

  operating_system {
    type = "l26"
  }

  serial_device {}

  startup {
    order      = 20
    up_delay   = 10
    down_delay = 30
  }
}
