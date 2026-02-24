{
  pkgs,
  config,
  ...
}:
{
  programs.ssh = {
    enable = true;
    forwardAgent = true;
    compression = true;
    hashKnownHosts = false;
    controlMaster = "no";

    matchBlocks = {
      "linux-builder" = {
        hostname = "localhost";
        port = 31022;
        user = "builder";
        identityFile = "/etc/nix/builder_ed25519";
        identitiesOnly = true;
        extraOptions = {
          StrictHostKeyChecking = "accept-new";
        };
      };
    };

    extraConfig = ''
      Host *
        HashKnownHosts no
        StrictHostKeyChecking no
        UserKnownHostsFile /dev/null
        ForwardAgent yes
    '';
  };

  home.packages = with pkgs; [
    bitwarden-cli
    bitwarden-desktop
  ];

  # home.sessionVariables = {
  #   SSH_AUTH_SOCK = "${config.home.homeDirectory}/.bitwarden-ssh-agent.sock";
  # };

  programs.zsh.initExtra = ''
    if [ -z "$SSH_CONNECTION" ]; then
       export SSH_AUTH_SOCK="${config.home.homeDirectory}/.bitwarden-ssh-agent.sock"
     fi
  '';
}
