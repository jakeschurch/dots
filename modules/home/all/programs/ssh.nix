{ pkgs, config, ... }:
{

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
  };

  home.packages = with pkgs; [
    bitwarden-cli
    bitwarden-desktop
  ];

  home.sessionVariables = {
    SSH_AUTH_SOCK = "${config.home.homeDirectory}/.bitwarden-ssh-agent.sock";
  };
}
