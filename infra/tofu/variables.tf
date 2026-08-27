variable "proxmox_endpoint" {
  description = "Proxmox API endpoint, e.g. https://192.168.1.10:8006/"
  type        = string
}

variable "proxmox_insecure" {
  description = "Allow Proxmox's self-signed TLS certificate"
  type        = bool
  default     = true
}

variable "node_name" {
  description = "Proxmox node name"
  type        = string
  default     = "pve"
}

variable "image_datastore" {
  description = "Datastore used for downloaded cloud images; must allow Import content"
  type        = string
  default     = "local"
}

variable "vm_datastore" {
  description = "Datastore used for the VM disk, typically SSD-backed local-lvm"
  type        = string
  default     = "local-lvm"
}

variable "bridge" {
  description = "Proxmox Linux bridge"
  type        = string
  default     = "vmbr0"
}

variable "games_vm_name" {
  type    = string
  default = "games-01"
}

variable "games_vm_id" {
  type    = number
  default = 200
}

variable "games_vm_cores" {
  type    = number
  default = 8
}

variable "games_vm_memory_mb" {
  type    = number
  default = 24576
}

variable "games_vm_disk_gb" {
  type    = number
  default = 200
}

variable "games_vm_ip_cidr" {
  description = "Static IPv4 address/CIDR for games-01, e.g. 192.168.1.50/24"
  type        = string
}

variable "games_vm_gateway" {
  description = "IPv4 default gateway"
  type        = string
}

variable "dns_servers" {
  description = "DNS servers passed via cloud-init"
  type        = list(string)
  default     = ["1.1.1.1", "9.9.9.9"]
}

variable "vm_username" {
  description = "Initial cloud-init SSH user"
  type        = string
  default     = "homelab"
}

variable "ssh_public_key_path" {
  description = "Path on the workstation to the SSH public key"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}
