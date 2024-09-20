# nextcloud-lxc-flake
NixOS flake for installing Nextcloud on Proxmox LXC.

DISCLAIMER: Work in progress

## Installation
### Create NixOS proxmox template and upload it to Proxmox
```bash
# Run on machine with Nix (not NixOS, only nix is required) already installed
nix run github:nix-community/nixos-generators -- --format proxmox-lxc
# Previous command will output path to generated tar archive - upload it to your Proxmox machine - for example
rsync -e ssh -avP /nix/store/ny24yz3f4vnbb24yziz1c5llmg873j5v-tarball/tarball/nixos-system-x86_64-linux.tar.xz proxmox.example.com:/tmp/nixos-default-template.tar.xz

# Run on Proxmox
cp /tmp/nixos-default-template.tar.xz /var/lib/vz/template/cache/
```
### Create Proxmox container
```bash

```
### Deploy flake
```bash

```