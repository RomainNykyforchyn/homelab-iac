# Architecture decisions

## Ownership boundaries

| Layer | Owns | Does not own |
|---|---|---|
| Proxmox | hypervisor, storage, bridges, VM lifecycle | game processes |
| OpenTofu | desired VM resources | guest package configuration |
| Ansible | guest OS packages/services/config | Proxmox VM lifecycle |
| Docker | application containers | VM lifecycle |
| Pterodactyl | game server lifecycle and allocations | Proxmox |
| playit.gg | public tunnels to selected ports | internal management network |

## Why one games VM instead of VM-per-game

Most game servers do not need a complete dedicated OS. Pterodactyl/Wings already isolates them with Docker and provides resource limits, console, files, allocations, and lifecycle management.

Use a separate Proxmox VM when a workload needs a different OS, substantially stronger isolation, GPU passthrough, incompatible dependencies, or a different trust boundary.

## Why playit runs in games-01

Keeping the tunnel agent in the workload VM avoids coupling public ingress to the Proxmox host. Pterodactyl game allocations become ordinary ports on the games VM, and playit forwards only the ports you choose.

## Future services

Do not put every homelab service in `games-01`. Add separate VMs/LXCs when their lifecycle or trust boundary differs, for example:

```text
Proxmox
├── games-01       Pterodactyl/Wings + playit
├── dns-01         Pi-hole/AdGuard
├── monitoring-01  Grafana/Prometheus/Uptime Kuma
└── k3s-*          disposable Kubernetes lab
```
