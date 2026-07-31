{
  pkgs,
  config,
  osConfig ? { profiles.desktop.enable = false; },
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

      "git.jakeschurch.com" = {
        User = "git";
        IdentityFile = "${config.home.homeDirectory}/.ssh/id_apollo";
        IdentitiesOnly = true;
        ProxyCommand = "${lib.getExe pkgs.cloudflared} access ssh --hostname %h";
        StrictHostKeyChecking = "accept-new";
      };

      "10.*.*.*" = {
        ForwardAgent = true;
        StrictHostKeyChecking = "no";
        UserKnownHostsFile = "/dev/null";
      };

      "*" = {
        ForwardAgent = true;
        Compression = true;
        HashKnownHosts = false;
        ControlMaster = "no";
        StrictHostKeyChecking = "accept-new";
      };
    };
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
