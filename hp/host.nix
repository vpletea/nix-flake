{
  pkgs,
  nixos-username,
  nixos-hostname,
  ...
}:

{
  imports = [
    /etc/nixos/hardware-configuration.nix
  ];

  # Bootloader setup
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    loader.timeout = 0; # ### Use the space key at boot for generations menu
    plymouth.enable = true;
    initrd.systemd.enable = true;
    initrd.systemd.tpm2.enable = false;
    kernelParams = [ "quiet" ];
  };

  # Disable TPM2 support
  systemd.tpm2.enable = false;

  # Set your time zone.
  time.timeZone = "Europe/Bucharest";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Zsh settings
  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;

  # Newtorking settings
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;

  # Define your hostname.
  networking.hostName = "${nixos-hostname}";
  # Allow unfree software
  nixpkgs.config.allowUnfree = true;
  # Define user account
  users.users."${nixos-username}" = {
    isNormalUser = true;
    description = nixos-username;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  # Packages installed system wide
  environment.systemPackages = with pkgs; [
    # System pkgs
    plymouth
    vim

    # General pkgs
    bat
    bitwarden
    chezmoi
    eza
    firefox
    fzf
    git
    htop
    gnomeExtensions.dash-to-dock
    google-chrome
    kitty
    mise
    nerd-fonts.jetbrains-mono
    onlyoffice-desktopeditors
    starship
    vlc
    winbox4
    zed-editor
    zoxide

    # Gnome related pkgs
    file-roller # File archiver
    gnome-console
    gnome-disk-utility
    nautilus # File manager
    loupe # Image viewer
  ];
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    nil
    nixd
  ];

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Configure printing - with drivers for hp printers
  services.printing = {
    enable = true;
    drivers = [ pkgs.hplipWithPlugin ];
  };

  # SSH agent setup
  programs.ssh.startAgent = true;

  # Yubikey required service
  services.pcscd.enable = true;

  # Enable windowing system
  services.xserver = {
    enable = true;
    excludePackages = [ pkgs.xterm ];
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };
  services.gnome.core-apps.enable = false;

  # Accelerated Video Playback
  nixpkgs.config.packageOverrides = pkgs: {
    intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
  };
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      libvdpau-va-gl
    ];
  };
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };

  # Power settings
  services.power-profiles-daemon.enable = false;
  services.thermald.enable = true;
  powerManagement.enable = true;

  # Auto-cpufreq settings
  services.auto-cpufreq.enable = true;
  services.auto-cpufreq.settings = {
    battery = {
      governor = "powersave";
      turbo = "never";
      energy_performance_preference = "balance_power";
    };
    charger = {
      governor = "performance";
      turbo = "auto";
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
