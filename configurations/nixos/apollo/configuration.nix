{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  boot = {
    extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];

    plymouth = {
      enable = true;
      theme = "lone";
      themePackages = with pkgs; [
        # By default we would install all themes
        (adi1090x-plymouth-themes.override {
          selected_themes = [ "lone" ];
        })
      ];
    };

    # Enable "Silent boot"
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "splash"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
      "amd_iommu=pt"
    ];
    loader = {
      # Use the systemd-boot EFI boot loader.
      systemd-boot.configurationLimit = 5;
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };

      timeout = 3;
    };

    initrd.kernelModules = [ "nvidia" ];
    kernelPackages = pkgs.linuxPackages_zen;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      # Intel Arc B580 compute support for LLM inference
      intel-compute-runtime # OpenCL
      intel-media-driver # VA-API
      level-zero # oneAPI Level Zero (for SYCL/llama.cpp)
      vpl-gpu-rt # Intel Video Processing Library

      # NVIDIA Vulkan support
      vulkan-loader
      vulkan-validation-layers
      vulkan-tools
    ];

    # Also need 32-bit packages for Steam games
    extraPackages32 = with pkgs.pkgsi686Linux; [
      mesa
      vulkan-loader
      libva
    ];
  };

  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    powerManagement.enable = true;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+
    open = true;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };

  networking = {
    hostName = "apollo"; # Define your hostname.
    # Pick only one of the below networking options.
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    networkmanager.enable = false;

    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    firewall.enable = false;
  }; # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = null;
    useXkbConfig = true; # use xkb.options in tty.
  };

  services = {
    xserver = {
      videoDrivers = [ "nvidia" ];
      # Configure keymap in X11
      xkb.layout = "us";
    };
    # services.xserver.xkb.options = "eurosign:e,caps:escape";

    # Enable CUPS to print documents.
    printing.enable = true;

    # Enable sound.
    pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      wireplumber.enable = true;
    };
  };

  users.users.root = {
    hashedPassword = "$6$6tPOnj6huVpiv72E$gJhLDPpWIo3X52aU6FXW81CGbwBBSh4chwuq7k/AcWafC5oKdzfW4XGy.yp6G92uzuJxUsFp4qt2LO9D28.D6/";
    home = "/root";
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jake = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      "lp"
      "lpadmin"
      "wheel"
      "video"
      "kvm"
    ]; # Enable ‘sudo’ for the user.
    hashedPassword = "$6$6tPOnj6huVpiv72E$gJhLDPpWIo3X52aU6FXW81CGbwBBSh4chwuq7k/AcWafC5oKdzfW4XGy.yp6G92uzuJxUsFp4qt2LO9D28.D6/";
    home = "/home/jake";
    packages = with pkgs; [
      tree
    ];
  };

  programs = {
    firefox.enable = true;
    zsh.enable = true;

    git.enable = true;
    bash.enable = true;

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # programs.mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  # Local pull-through Nix binary cache proxy
  services.ncps = {
    enable = true;
    cache = {
      hostName = "apollo";
      maxSize = "50G";
      lru.schedule = "0 2 * * *";
    };
    server.addr = "127.0.0.1:8501";
    upstream = {
      caches = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://hyprland.cachix.org"
      ];
      publicKeys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };
  };

  # Override substituters to use local ncps pull-through cache
  nix.settings.substituters = lib.mkForce [
    "http://localhost:8501"
  ];

  nix.settings.trusted-substituters = lib.mkForce [
    "http://localhost:8501"
  ];

  nix.settings.trusted-public-keys = lib.mkForce [
    "apollo:i756C7FtllWIbgQipbcvBE3plUXT3ojFhSWcZOuDyHs="
  ];

  virtualisation.libvirtd.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    pavucontrol
    pamixer
    mesa-demos
  ];

  security.rtkit.enable = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?

  # More aggressive fsync/flush to prevent corruption
  boot.kernel.sysctl = {
    "vm.dirty_expire_centisecs" = 300; # Expire dirty pages faster
    "vm.dirty_ratio" = 10; # Reduce dirty page buffer
"vm.dirty_background_ratio" = 5;
  };

swapDevices = [
{ device = "/dev/disk/by-partlabel/disk-swap";}
];

  # Enable automatic BTRFS scrubbing to detect corruption early
  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    fileSystems = [ "/" ];
  };

  services.btrbk = {
    instances.btrbk = {
      onCalendar = "hourly";
      settings = {
        snapshot_preserve_min = "1d";
        snapshot_preserve = "7d 4w";
        volume."/" = {
          snapshot_dir = "/.snapshots";
          subvolume = {
            "/" = { };
            "/home" = { };
            "/home/jake" = { };
          };
        };
      };
    };
  };
}
