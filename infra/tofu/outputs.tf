output "games_vm_ip" {
  description = "IPv4 address without CIDR suffix"
  value       = split("/", var.games_vm_ip_cidr)[0]
}

output "games_vm_user" {
  value = var.vm_username
}

output "games_vm_name" {
  value = proxmox_virtual_environment_vm.games.name
}

output "games_vm_id" {
  value = proxmox_virtual_environment_vm.games.vm_id
}
