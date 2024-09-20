{ pkgs, config, modulesPath, ... }:

{
  ## Import LXC modules
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
  ];

  ## Basic settings
  system.stateVersion = "24.05"; # no need to touch, should be the same nix channel used on machine on which template was genereated using nixos-generators
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "x86_64-linux";

  ## Nextcloud
  services.nextcloud = {
    enable = true;
    hostName = "nc.example.com"; # Enter your domain here
    package = pkgs.nextcloud29; # Need to manually increment with every major upgrade.
    database.createLocally = true; # Let NixOS install and configure the database automatically.
    configureRedis = true; # Let NixOS install and configure Redis caching automatically.
    maxUploadSize = "16G"; 
    autoUpdateApps.enable = false;
    extraAppsEnable = true;
    extraApps = with config.services.nextcloud.package.packages.apps; {
      # List of already packaged apps:
      # https://github.com/NixOS/nixpkgs/blob/master/pkgs/servers/nextcloud/packages/nextcloud-apps.json
      inherit calendar contacts;
      ## Custom app example
      #socialsharing_telegram = pkgs.fetchNextcloudApp rec {
      #  url =
      #    "https://github.com/nextcloud-releases/socialsharing/releases/download/v3.0.1/socialsharing_telegram-v3.0.1.tar.gz";
      #  license = "agpl3";
      #  sha256 = "sha256-8XyOslMmzxmX2QsVzYzIJKNw6rVWJ7uDhU1jaKJ0Q8k=";
      #};
    };
    settings = {
      default_phone_region = "PL";
      overwriteprotocol = "https";
      log_type = "file";
      loglevel = 1;
    };
    config = {
      dbtype = "pgsql";
      adminuser = "admin";
      adminpassFile = "/var/nc_admin_pass";
    };
    phpOptions."opcache.interned_strings_buffer" = "16";
  };

  ## Additional packages
  environment.systemPackages = with pkgs; [
    vim
    git
    dust
    fd
    ripgrep
    tree
  ];

  ## Bash (aliases and history size)
  programs.bash = {
    shellAliases = {
      ll = "ls -alh";
    };
    shellInit = ''
      HISTTIMEFORMAT="%d/%m/%y %T "
      HISTSIZE=500000
      HISTFILESIZE=500000
      '';
  };

  ## Firewall
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 ]; # is 22 needed?
  };

  ## Locales
  time.timeZone = "Europe/Warsaw";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pl_PL.UTF-8";
    LC_IDENTIFICATION = "pl_PL.UTF-8";
    LC_MEASUREMENT = "pl_PL.UTF-8";
    LC_MONETARY = "pl_PL.UTF-8";
    LC_NAME = "pl_PL.UTF-8";
    LC_NUMERIC = "pl_PL.UTF-8";
    LC_PAPER = "pl_PL.UTF-8";
    LC_TELEPHONE = "pl_PL.UTF-8";
    LC_TIME = "pl_PL.UTF-8";
  };
}
