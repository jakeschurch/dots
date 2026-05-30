{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  networking = {
    hostName = "artemis";
    networkmanager.enable = false;
    firewall.enable = false;
  };

  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";

  users.users.root = {
    hashedPassword = "$6$6tPOnj6huVpiv72E$gJhLDPpWIo3X52aU6FXW81CGbwBBSh4chwuq7k/AcWafC5oKdzfW4XGy.yp6G92uzuJxUsFp4qt2LO9D28.D6/";
    home = "/root";
  };

  users.users.jake = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "kvm"
      "docker"
    ];
    hashedPassword = "$6$6tPOnj6huVpiv72E$gJhLDPpWIo3X52aU6FXW81CGbwBBSh4chwuq7k/AcWafC5oKdzfW4XGy.yp6G92uzuJxUsFp4qt2LO9D28.D6/";
    home = "/home/jake";
  };

  programs = {
    zsh.enable = true;
    git.enable = true;
    bash.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
  ];

  documentation.nixos.enable = false;

  system.stateVersion = "25.05";
}
