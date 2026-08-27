# After the first successful `tofu apply`

1. Inspect outputs:

   ```bash
   make tofu-output
   ```

2. Wait for cloud-init to finish, then test SSH using the VM IP from the output:

   ```bash
   ssh homelab@<games_vm_ip>
   ```

   If you use a dedicated SSH key and it is not already loaded:

   ```bash
   ssh-add ~/.ssh/homelab_iac
   ```

3. Generate the Ansible inventory:

   ```bash
   make inventory
   ```

4. Test Ansible connectivity:

   ```bash
   make ansible-ping
   ```

5. Apply the base configuration. This installs baseline packages, qemu-guest-agent, and Podman. Playit remains disabled initially.

   ```bash
   make ansible-games
   ```

6. Verify Podman on the VM:

   ```bash
   ssh homelab@<games_vm_ip> podman --version
   ```

7. Only after that, create the encrypted Playit secret vault and enable Playit.
