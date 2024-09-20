# nextcloud-lxc-flake
NixOS flake for installing Nextcloud in Proxmox LXC.
## Installation
### Create NixOS proxmox template and upload it to Proxmox
```bash
# Run on machine with Nix (not NixOS, only nix is required - probably, not tested) already installed:
nix run github:nix-community/nixos-generators -- --format proxmox-lxc
# Previous command will output path to generated tar archive - upload it to your Proxmox machine - for example
rsync -e ssh -avP /nix/store/ny24yz3f4vnbb24yziz1c5llmg873j5v-tarball/tarball/nixos-system-x86_64-linux.tar.xz proxmox.example.com:/tmp/nixos-template.tar.xz

# Run on Proxmox:
cp /tmp/nixos-template.tar.xz /var/lib/vz/template/cache/
```
### Create Proxmox container
Of course with your desired settings. Example:
```bash
pct create 100 /var/lib/vz/template/cache/nixos-template.tar.xz --hostname nextcloud --memory 2048 --net0 name=eth0,bridge=vmbr0,firewall=0,gw=192.168.10.1,ip=192.168.10.71/24 --storage local --rootfs local:20 --unprivileged 1 --ignore-unpack-errors --ostype nixos --password="$ROOTPASS" --start 1
```
This can be also done from Proxmox Web GUI - "Create CT" button.
### Deploy flake on container
```bash
pct enter 100 # or your real CT ID
# enter bash shell
/run/current-system/sw/bin/bash
# update packages, while we do not have flake
nix-channel --update
# temporary install needed tools
nix-shell -p vim git pwgen
# generate password for admin
passwd 24 1 > /var/nc_admin_pass
chmod 640 /var/nc_admin_pass
# get repo with configuration definition
git clone https://github.com/patrykpwrona/nextcloud-lxc-flake.git
# deploy
cd nextcloud-lxc-flake
## nix flake update . --extra-experimental-features "nix-command flakes" - optional - only when no flake.lock is present
nixos-rebuild switch --flake ./#nextcloud
```

## Usage
```bash
# check version
nextcloud-occ --version
```

## Update
### Major
```bash
cd nextcloud-lxc-flake
vim configuration.nix # change package - e.g. pkgs.nextcloud29 to pkgs.nextcloud30
nix flake update .
nixos-rebuild switch --flake ./#nextcloud
```
### Minor
```bash
cd nextcloud-lxc-flake
nix flake update .
nixos-rebuild switch --flake ./#nextcloud
```

## Considerations
* This takes a lot of disk space - almost 5 GB
* Probably using nixos-generators and configuration.nix file we can generate ready image - with nextcloud installed. And then we create LXC using it.