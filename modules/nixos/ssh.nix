{
  flake,
  pkgs,
  ...
}:
let
  inherit (flake) config;
in
{
  programs.mosh.enable = true;

  programs.ssh = {
    extraConfig = ''
      Host *
        HashKnownHosts=no
        StrictHostKeyChecking=no
        UserKnownHostsFile=/dev/null
    '';
  };

  users.users.${config.me.username}.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDlvt0yfoDKebGXoDFo3sC3oikAT9IdfQmSJKlAjxZrlbGLSIS+IRLXjzftNomkDRUtbS/W90d2a+BYjbiJfUOSCp1rOcAJqp6exgDNicLi7IZoM/BRsyegGYSQJ0RAJVJMMe/vICsQ9jKeIt3125Z/MAFRF4XIdwk7Vxjf/BGCwRBpsEPNme4V/Oo1BSTSgrxW/K5Lr4JFPHf++z2BVUyxJOQD2ZH6KqRNuUeGZRzwSz3amDYG0o8+DbLlTIWFAS+tOqzmOvUedmGr99oyt4kXmXlfzJB+GeKgIBxOiPiKI+XCPNu0y0zFMTcNDL12S4HTz+wL7ZcdOdDLAAdd/W/R/WuGnhfik6sHD/2m0+ER02IyE2xakvMdEiHU43kywjkYzoKANNifdrCFcpAyJcn8ERT6b7buP433OQaVpURPpeY9RjPLteYqCHpQI+cpEQGtFFjMnAgPIexoL1sQ/0tvAf1IQVF5kvTior6C8egyOqsbd7VMy99s0u33NtRbwqfAmkc8aCJGmo3G0WwiVwq+dNmvcP9Wrllzxlha5VmkJCt8qFGWuafj1pfo3ZP22aGKdisPwCo6ZKLTRvAAmRhSSTsVD+U+Tlx8F1frekU4/kwFSXxZafj9Sw6ekaLg+bQRwIWLXApT8dhkoq8fLSwhZ62DlBqx4pn2zC7FcoBSuQ== jake@Apollo"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKfXxg1EoEPjICGcwbhmLP7CRRGCFc7GAWE0znnYmRYw"
  ];

  environment.systemPackages = with pkgs; [
    bitwarden-cli
  ];

  services = {
    endlessh.enable = true;
    sshd.enable = true;

    openssh = {
      enable = true;
      ports = [ 22222 ];
      settings = {
        PasswordAuthentication = false;
        UseDns = true;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        AllowUsers = [ config.me.username ];
      };
    };
  };
}
