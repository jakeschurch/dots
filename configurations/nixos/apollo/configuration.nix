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

  networking = {
    hostName = "apollo";
    networkmanager.enable = false;
    firewall.enable = false;
  };

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = null;
    useXkbConfig = true; # use xkb.options in tty.
  };

  services = {
    xserver = {
      # Configure keymap in X11
      xkb.layout = "us";
    };

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

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.jake = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      "lp"
      "lpadmin"
      "wheel"
      "video"
      "kvm"
    ];
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
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  virtualisation.libvirtd.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    wget
    pavucontrol
    pamixer
  ];

  security.rtkit.enable = true;

  # This value defines the first NixOS version you installed on this machine.
  # Do NOT change this value unless you have manually inspected all changes it would make.
  system.stateVersion = "25.05"; # Did you read the comment?
}
