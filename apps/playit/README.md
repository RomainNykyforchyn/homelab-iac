# playit.gg

The playit agent is deployed by Ansible rather than manually from this directory.

Design choice:

```text
playit agent
  -> runs inside games-01
  -> Docker host networking
  -> reaches ports published on games-01
  -> never needs to run on the Proxmox host
```

Later, Pterodactyl/Wings will publish each game's allocated port on `games-01`. Configure the matching playit tunnel to forward to that local IP/port.
