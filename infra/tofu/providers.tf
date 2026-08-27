provider "proxmox" {
  endpoint = var.proxmox_endpoint
  insecure = var.proxmox_insecure

  # Authentication is intentionally not stored in .tf files.
  # Export PROXMOX_VE_API_TOKEN before running OpenTofu.
}
