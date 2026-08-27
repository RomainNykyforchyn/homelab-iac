SHELL := /usr/bin/env bash

.PHONY: source tofu-init tofu-fmt tofu-plan tofu-apply tofu-destroy tofu-output inventory ansible-requirements ansible-ping ansible-games

source:
	source ~/.config/homelab-iac/secrets.env

tofu-init:
	cd infra/tofu && tofu init

tofu-fmt:
	tofu fmt -recursive infra/tofu

tofu-plan:
	cd infra/tofu && tofu plan

tofu-apply:
	cd infra/tofu && tofu apply

tofu-output:
	cd infra/tofu && tofu output

tofu-destroy:
	cd infra/tofu && tofu destroy

inventory:
	./scripts/render-inventory.sh

ansible-requirements:
	cd ansible && ansible-galaxy collection install -r requirements.yml

ansible-ping:
	cd ansible && ansible -i inventory/hosts.yml games -m ping

ansible-games:
	cd ansible && ansible-playbook -i inventory/hosts.yml playbooks/games.yml
