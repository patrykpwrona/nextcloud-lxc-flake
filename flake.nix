{
  description = "Nextcloud on NixOS LXC on Proxmox";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }@inputs : 
    let
      pkgs = import nixpkgs;
    in
    {
      nixosConfigurations."nextcloud" = nixpkgs.lib.nixosSystem {
        modules = [
          ./configuration.nix
        ];
      };
    };
}


