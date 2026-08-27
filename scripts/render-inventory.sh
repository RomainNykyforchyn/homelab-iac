#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOFU_DIR="$ROOT_DIR/infra/tofu"
OUT="$ROOT_DIR/ansible/inventory/hosts.yml"

if ! command -v tofu >/dev/null 2>&1; then
  echo "OpenTofu (tofu) is not installed or not in PATH." >&2
  exit 1
fi

IP="$(cd "$TOFU_DIR" && tofu output -raw games_vm_ip)"
USER="$(cd "$TOFU_DIR" && tofu output -raw games_vm_user)"
NAME="$(cd "$TOFU_DIR" && tofu output -raw games_vm_name)"

cat > "$OUT" <<YAML
all:
  children:
    games:
      hosts:
        ${NAME}:
          ansible_host: ${IP}
          ansible_user: ${USER}
YAML

printf 'Wrote %s (%s@%s)\n' "$OUT" "$USER" "$IP"
