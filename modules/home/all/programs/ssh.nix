{
  pkgs,
  config,
  osConfig,
  lib,
  ...
}:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      "linux-builder" = {
        Hostname = "localhost";
        Port = 31022;
        User = "builder";
        IdentityFile = "/etc/nix/builder_ed25519";
        IdentitiesOnly = true;
        StrictHostKeyChecking = "accept-new";
      };

      "*" = {
        ForwardAgent = true;
        Compression = true;
        HashKnownHosts = false;
        ControlMaster = "no";
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

  home.packages =
    with pkgs;
    [ bitwarden-cli ]
    ++ lib.optionals osConfig.profiles.desktop.enable [
      bitwarden-desktop
    ];

  programs.zsh.initContent = lib.optionalString osConfig.profiles.desktop.enable ''
    if [ -z "$SSH_CONNECTION" ]; then
       export SSH_AUTH_SOCK="${config.home.homeDirectory}/.bitwarden-ssh-agent.sock"
     fi
  '';

  programs.fish.shellInit = lib.optionalString osConfig.profiles.desktop.enable ''
    if test -z "$SSH_CONNECTION"
      set -gx SSH_AUTH_SOCK "$HOME/.bitwarden-ssh-agent.sock"
    end
  '';
}
