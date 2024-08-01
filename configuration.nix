{ config, pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
    ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.efiSysMountPoint = "/boot";
    efi.canTouchEfiVariables = true;
  };
  boot.initrd.systemd.enable = true;

  boot.kernel.sysctl = { "vm.swappiness" = 10;};

  networking = {
    hostName = "rogue";
    hostId = "8425e349";
    domain = "m0rr1s.com";
    dhcpcd.enable = false;
    interfaces.enp4s0.ipv4.addresses = [{
      address = "10.10.5.50";
      prefixLength = 24;
    }];
    defaultGateway = "10.10.5.1";
    nameservers = [ "10.10.10.2" "75.75.75.75" ];
  };

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver = {
    enable = true;
    desktopManager = {xterm.enable=false;};
    displayManager = {
      defaultSession = "none+i3";
    };
    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu
        i3status
        i3lock
        i3blocks
      ];
    };
  };
  services.xserver.windowManager.i3.package = pkgs.i3-gaps;

  # Enable OpenGL
  hardware.opengl = {
    enable = true;
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting
    open = false;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  programs.dconf.enable = true;
  
  services.printing.enable = true;

  # Enable sound with pipewire. 
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
 
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  services.blueman.enable = true;

  # Don't allow mutation of users outside of the config.
  users.mutableUsers = false;

  users.users = {
    ray = {
      createHome = true;
      isNormalUser = true;
      extraGroups = [
        "wheel"
      ];
      initialHashedPassword = "$6$1wcXL3g7LKmllxZl$pDk5Y9JJ0JaiaY4Uf1X/0jzm11gkGyfp4K72jIfqce1ZCJP5qauAAz9kIqI8Zcm3zETSPk0zA4UchPHmLf/fY.";
    };
    root = {
      extraGroups = [
        "wheel"
      ];
      initialHashedPassword = "$6$hkcLPiBP7COaGEj0$p3sJKeIRxOxtUzFEM6mkEm1JfLAh7SNvh3enQ9QSBlPqtZ.8dJAQ6AsHTBQL9MgSPv/is6nHHcDKsRu4xA27c0";
    };
  };

  security.sudo.extraRules= [
    {  users = [ "ray" ];
      commands = [
        { command = "ALL" ;
          options= [ "NOPASSWD" "SETENV"];
        }
      ];
    }
  ];

  programs.nano.enable = false;

  services.openssh.settings = {
    enable = true;
    kexAlgorithms = [ "curve25519-sha256" ];
    ciphers = [ "chacha20-poly1305@openssh.com" ];
    passwordAuthentication = true;
    permitRootLogin = "yes";
    kbdInteractiveAuthentication = true;
  };

  environment.systemPackages = with pkgs; [
    wget
    vim
    neovim
    curl
    cmatrix
    neofetch
    rofi
    xfce.thunar
    htop
    git
    xfce.ristretto
    feh
    lxappearance
    imagemagick
    zip
    jq
    unzip
    qemu_kvm

    brave
    vscodium
    jetbrains-toolbox
    alacritty
  ];

  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true; # Thumbnail support for images

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # for the picom
  #services.picom.enable = true;
  services.picom = {
    enable = true;
    fade = true;
    shadow = true;
    fadeDelta = 4;
    inactiveOpacity = 0.8;
    activeOpacity = 1;
    settings = {
      blur = {
        strength = 5;
      };
    };
  };

  zramSwap = {
    enable = true;
    memoryPercent = 25;
    priority = 10;
  };

  system.stateVersion = "24.05";

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  system.autoUpgrade = {
    enable = true;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
