{ pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  profiles.desktop.enable = false;

  # sops-nix derives age key from existing SSH host key — no separate key file needed
  # jake@artemis SSH key — must be placed at this path before first nixos-switch
  sops.age.sshKeyPaths = [ "/home/jake/.ssh/id_ed25519_artemis" ];

  networking = {
    hostName = "artemis";
    networkmanager.enable = false;
    firewall.enable = false;

    # LACP 802.3ad bond over both 10GbE NICs (Broadcom BCM57416, Cat6, CSS326-24G-2S+)
    bonds.bond0 = {
      interfaces = [
        "eno1np0"
        "eno2np1"
      ];
      driverOptions = {
        mode = "802.3ad";
        lacp_rate = "fast";
        miimon = "100";
        xmit_hash_policy = "layer3+4";
      };
    };

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

  # vmetal's microvm-host generates 01-external.network with DHCP on externalInterface.
  # Override to static IP — 01-prefix ensures this still wins over NixOS-generated 40-bond0.network.
  systemd.network.networks."01-external" = lib.mkForce {
    matchConfig.Name = "bond0";
    networkConfig = {
      DHCP = "no";
      IPv6PrivacyExtensions = "kernel";
      Address = "10.10.5.110/24";
    };
    routes = [ { Gateway = "10.10.5.1"; } ];
    linkConfig.MTUBytes = 9000;
  };

  documentation.nixos.enable = false;

  # Derive age key from SSH key and place at /etc/sops/age/keys.txt
  # Required by vmetal microvm-host to share age keys with VMs via virtiofsd
  system.activationScripts.deriveAgeKey = {
    deps = [ "users" "groups" ];
    text = ''
      mkdir -p /etc/sops/age
      ${lib.getExe pkgs.ssh-to-age} -private-key -i /home/jake/.ssh/id_ed25519_artemis > /etc/sops/age/keys.txt
      chmod 600 /etc/sops/age/keys.txt
    '';
  };

  system.stateVersion = "25.05";
}
