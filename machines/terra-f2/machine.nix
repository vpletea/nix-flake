{ config, pkgs, ... }:
let
  nixos-username = "valentin";
  nixos-hostname = "f2";
in
{
  imports = [
    ./disko.nix
    ./hardware.nix
  ];

  # Bootloader setup
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1; # Use the space key at boot for generations menu
  boot.plymouth.enable = true;
  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.tpm2.enable = false;
  boot.kernelParams = [ "quiet" ];
  boot.supportedFilesystems = [ "zfs" ];
  networking.hostId = "dceadcbf";

  # Networking settings
  networking.hostName = "${nixos-hostname}"; # Define your hostname.
  networking.firewall.enable = false; # Disable the firewall altogether
  #  networking.useDHCP = false;
  #  networking.interfaces.enp0s21f0u5.ipv4.addresses = [{ address = "192.168.1.201"; prefixLength = 24; }];
  #  networking.defaultGateway = "192.168.1.1";
  #  networking.nameservers = [ "192.168.1.1" ];

  nixpkgs.config.allowUnfree = true; # Allow unfree software
  security.sudo.wheelNeedsPassword = false; # Passwordless sudo for wheel group
  users.users."${nixos-username}" = {
    # Define user account
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
    openssh.authorizedKeys.keys = [
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAILQwflbQ5CDJhaGSigNSrq0CmZbL82cdtBY2nylJAM9ZAAAAEXNzaDpZdWJpa2V5LVVTQi1D valentin@terra-nix"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIB8RMwwUKZuPhLydiLtB/KWuKAkGF2VStrm+DDUPy+1dAAAAEXNzaDpZdWJpS2V5LVVTQi1B valentin@terra-nix"
    ];
  };

  # Timezone and locale settings
  time.timeZone = "Europe/Bucharest"; # Set your time zone.
  i18n.defaultLocale = "en_US.UTF-8"; # Select internationalisation properties.

  # Packages installed in system profile
  environment.systemPackages = with pkgs; [
    htop
  ];

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.PermitRootLogin = "no";
  };

  # Git setup
  programs.git = {
    enable = true;
    config = {
      user.email = "84437690+vpletea@users.noreply.github.com";
      user.name = "vpletea";
      init = {
        defaultBranch = "main";
      };
    };
  };

  nix = {
    # Enable flakes support
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      warn-dirty = false;
    };
    # Automate garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 15";
    };
  };

  system.stateVersion = "24.11"; # Set the state version - no need to change
}
