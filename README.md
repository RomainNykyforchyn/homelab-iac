# homelab-iac

A small, intentionally boring homelab stack:

- **Proxmox VE** = physical virtualization layer
- **OpenTofu** = creates VMs
- **Ansible** = configures guest operating systems
- **Docker** = runs application containers
- **Pterodactyl** = manages individual game servers
- **playit.gg** = exposes selected game ports without router port-forwarding

The first milestone in this repo creates one Ubuntu 24.04 `games-01` VM, installs Docker, and can run the official playit.gg agent inside that VM. Pterodactyl is the next layer; it is deliberately not auto-installed in the first commit so the infrastructure and networking can be verified independently first.

## Architecture

```text
Internet
   |
playit.gg
   |
playit agent (Docker, host networking)
   |
+-----------------------+
| games-01 VM           |
| Ubuntu 24.04          |
| Docker                |
| Pterodactyl Wings (*) |
| game containers (*)   |
+-----------------------+
   |
 vmbr0
   |
Proxmox VE

(*) added in the next phase
```

Keep the Proxmox web UI and management interfaces on your LAN/VPN. Only tunnel the game ports you actually want public.

## Repo layout

```text
infra/tofu/              Proxmox VM definitions
ansible/                  Guest OS configuration
apps/                     App-level definitions/config examples
scripts/                  Glue between layers
docs/                     Architecture notes
```

## 0. Prerequisites on your workstation

Install:

- OpenTofu
- Ansible
- an SSH key, e.g. `~/.ssh/id_ed25519.pub`

The workstation can be your normal desktop/laptop; these tools do not need to run on Proxmox itself.

## 1. One-time Proxmox preparation

### Enable image import on a datastore

The OpenTofu config downloads an Ubuntu cloud image into the Proxmox `local` datastore as an import image.

In the Proxmox UI:

`Datacenter -> Storage -> local -> Edit -> Content`

Make sure **Import** is enabled. If you prefer another datastore, change `image_datastore` in `terraform.tfvars`.

### Create an API token

Create a dedicated Proxmox API user/token for OpenTofu. Export the token locally rather than committing it:

```bash
export PROXMOX_VE_API_TOKEN='opentofu@pve!provider=YOUR_TOKEN_SECRET'
```

Use the Proxmox/bpg provider permission documentation to grant only the privileges required by the resources you use. Do not commit the token.

## 2. Configure OpenTofu

```bash
cp infra/tofu/terraform.tfvars.example infra/tofu/terraform.tfvars
$EDITOR infra/tofu/terraform.tfvars
```

Pick an unused static LAN address for `games_vm_ip_cidr`. A DHCP reservation for that address is also a good idea.

Then:

```bash
make tofu-init
make tofu-plan
make tofu-apply
```

OpenTofu will create `games-01` and configure its initial SSH user through cloud-init.

## 3. Generate Ansible inventory

```bash
make inventory
```

This reads the VM IP and SSH username from OpenTofu outputs and creates:

```text
ansible/inventory/hosts.yml
```

That file is intentionally ignored by Git.

## 4. Configure the games VM

Install the required Ansible collection:

```bash
make ansible-requirements
```

Then configure the VM:

```bash
make ansible-games
```

This installs baseline packages, QEMU guest agent, Podman.

## 5. Enable playit.gg

The playit agent runs as a Podman container using host networking and a systemd Quadlet. This repo keeps its secret out of Git.

First obtain an agent secret from playit.gg, then create an encrypted Ansible Vault file:

```bash
ansible-vault create ansible/group_vars/vault.yml
```

Put the variable below in the editor that opens. The resulting file is encrypted and is also ignored by Git.

Set:

```yaml
vault_playit_secret_key: "YOUR_PLAYIT_SECRET"
```

Then edit:

```text
ansible/group_vars/games.yml
```

and change:

```yaml
playit_enabled: true
```

Run Ansible again:

```bash
make ansible-games
```

The playit container uses host networking, so tunnels can target ports published on the `games-01` VM by game servers later.

## 6. Next phase: Pterodactyl

Once these are verified:

```text
OpenTofu -> creates games-01
Ansible  -> configures games-01
Podman   -> healthy
playit   -> connected
```

add Pterodactyl Panel + Wings. Note: Wings currently remains the one layer where Docker is the conservative choice; do not create one Proxmox VM per game unless a specific game needs a separate OS or stronger isolation.

## Security notes

- Never commit Proxmox API tokens, SSH private keys, or playit secrets.
- Do not expose Proxmox `:8006` through playit.
- Prefer LAN/VPN access for Pterodactyl admin, SSH, and Proxmox management.
- Treat privileged container-management access as effectively root access to the VM.
- Back up Pterodactyl databases/configuration and game data to your Proxmox backup storage.
