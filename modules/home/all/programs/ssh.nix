{
  pkgs,
  config,
  ...
}:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

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

      "*" = {
        forwardAgent = true;
        compression = true;
        hashKnownHosts = false;
        controlMaster = "no";
      };
    };

    extraConfig = ''
      Host *
        StrictHostKeyChecking no
        UserKnownHostsFile /dev/null

      Host 10.*.*.*
        UserKnownHostsFile /dev/null
        ForwardAgent Yes
    '';
  };

  home.packages = with pkgs; [
    bitwarden-cli
    bitwarden-desktop
  ];

  programs.zsh.initContent = ''
    if [ -z "$SSH_CONNECTION" ]; then
       export SSH_AUTH_SOCK="${config.home.homeDirectory}/.bitwarden-ssh-agent.sock"
     fi
  '';

  programs.fish.shellInit = ''
    if test -z "$SSH_CONNECTION"
      set -gx SSH_AUTH_SOCK "$HOME/.bitwarden-ssh-agent.sock"
    end
  '';

}
