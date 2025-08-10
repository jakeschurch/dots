_: {
  programs.ssh = {
    enable = true;
    forwardAgent = false;
    compression = true;
    hashKnownHosts = false;
    controlMaster = "no";
    extraConfig = ''
      Host *
        HashKnownHosts=no
        StrictHostKeyChecking=no
        UserKnownHostsFile=/dev/null
    '';
    matchBlocks = {
      # REVIEW
      # remote-cloudflare = {
      #   host = "bastion.jakeschurch.com";
      #   user = "bastion";
      #   identityFile = "~/.ssh/id_homelab";
      #   port = 65534;
      #   proxyCommand = "cloudflared access ssh --hostname %h";
      # };
      apollo-pve = {
        host = "apollo.homelab";
        user = "root";
        identityFile = "~/.ssh/id_homelab";
        port = 22;
      };

      pve = {
        host = "pve.homelab";
        user = "root";
        identityFile = "~/.ssh/id_homelab";
        port = 22;
      };

      homelab-internal = {
        host = "10.10.5.*";
        user = "nixos";
        identityFile = "~/.ssh/id_homelab";
        port = 22;
      };

      apollo = {
        host = "10.10.6.4";
        user = "jake";
        identityFile = "~/.ssh/id_apollo";
        port = 22;
      };
      curiosity = {
        host = "10.10.6.9";
        user = "jake";
        identityFile = "~/.ssh/id_curiosity";
        port = 22;
      };

      "10.10.10.3" = {
        host = "10.10.10.3";
        identityFile = "~/.ssh/id_homelab";
        port = 22;
        # TODO
        # extraConfig = ''
        #   KexAlgorithms +diffie-hellman-group1-sha1
        #   HostKeyAlgorithms +ssh-rsa
        #   PubkeyAcceptedAlgorithms +ssh-rsa
        # '';
      };

      # git-internal = {
      #   host = "git-ssh.jakeschurch.com";
      #   user = "git";
      #   identityFile = "~/.ssh/id_rsa_github";
      #   port = 443;
      #   proxyCommand = "cloudflared access ssh --hostname %h";
      # };
      gitlab = {
        host = "gitlab.com";
        user = "git";
        identityFile = "~/.ssh/id_gitlab";
      };
    };
  };
}
