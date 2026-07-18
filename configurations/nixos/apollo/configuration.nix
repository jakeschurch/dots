{
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  tablet.enable = true;

  sops.age.sshKeyPaths = [ "/home/jake/.ssh/id_apollo" ];

  # Shared login hash for root + jake, decrypted at activation.
  # neededForUsers makes it available before user creation.
  sops.secrets."user-password" = {
    sopsFile = ../../../secrets/system.yaml;
    neededForUsers = true;
  };

  networking = {
    hostName = "apollo";
    networkmanager.enable = false;
    firewall.enable = false;
  };

  # vmetal generates 01-external.network with DHCP — override with static IP
  systemd.network.networks."01-external" = lib.mkForce {
    matchConfig.Name = "enp5s0";
    networkConfig = {
      DHCP = "no";
      IPv6PrivacyExtensions = "kernel";
      Address = "10.10.5.7/24";
    };
    routes = [ { Gateway = "10.10.5.1"; } ];
    # Jumbo frames — CSS326 passes 9204 natively; UDM Pro jumbo toggle = 9000.
    # Enables 9000 MTU end-to-end for cross-host pod + Mayastor NVMf traffic.
    # microvm-br + TAP + VM eth0 already set to 9000 in vmetal. (2026-06-24)
    linkConfig.MTUBytes = 9000;
  };

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = null;
    useXkbConfig = true; # use xkb.options in tty.
  };

  programs.xwayland.enable = true;

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
    hashedPasswordFile = config.sops.secrets."user-password".path;
    home = "/root";
  };

  # Define a user account. Don't forget to set a password with 'passwd'.
  hardware.i2c.enable = true; # DDC/CI for monitor brightness (noctalia)

  users.users.jake = {
    isNormalUser = true;
    extraGroups = [
      "lp"
      "lpadmin"
      "wheel"
      "video"
      "kvm"
      "docker"
      "i2c"
    ];
    hashedPasswordFile = config.sops.secrets."user-password".path;
    home = "/home/jake";
    packages = with pkgs; [
      tree
    ];
  };

  programs = {
    # firefox is managed by home-manager (modules/home/all/programs/browser.nix),
    # which installs the binary and owns the profile. No system-level dup needed.
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
    xauth
    ddcutil
  ];

  security.rtkit.enable = true;

  documentation.nixos.enable = false;

  # Reduce enp5s0 to 1 combined queue (from 2) to eliminate TX multi-queue
  # interleaving. With 2 queues under the mq qdisc, different softirq CPUs
  # route forwarded VM packets to different TX sub-queues, causing out-of-order
  # delivery for the same TCP flow on the artemis side (observed: 34.8M fast
  # retransmits / 26h, 85K rcv_ooopack on a single harbor→worker connection).
  # Also bump RX ring 256→4096 to stop rx_missed_errors under burst load.
  # (2026-06-23)
  systemd.services.enp5s0-nic-tuning = {
    description = "NIC queue and ring-buffer tuning for enp5s0";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.ethtool}/bin/ethtool -L enp5s0 combined 1 || true
      ${pkgs.ethtool}/bin/ethtool -G enp5s0 rx 4096    || true
    '';
  };

  # MTU blackhole detection — switches to MTU-capped segments when a path
  # silently drops oversized packets. Safe on cluster networks. (2026-06-23)
  boot.kernel.sysctl."net.ipv4.tcp_mtu_probing" = 2;

  # This value defines the first NixOS version you installed on this machine.
  # Do NOT change this value unless you have manually inspected all changes it would make.
  system.stateVersion = "25.05"; # Did you read the comment?
}
