{
  pkgs,
  config,
  osConfig ? {
    profiles.desktop.enable = false;
  },
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

      # Same forgejo as git.jakeschurch.com above, reached directly over the
      # LAN instead of through Cloudflare Access.
      #
      # That entry's ProxyCommand (`cloudflared access ssh`) forces an
      # interactive browser SSO login on EVERY push, which makes routine
      # pushes depend on a human completing an SSO flow — and forgejo is the
      # source of truth for the cluster (the GitHub remote is a push mirror
      # OUT of it, and ArgoCD reads forgejo), so a blocked push means nothing
      # deploys. forgejo-ssh is now a LoadBalancer on the cilium default-pool
      # at a pinned address (vmetal lib/apps/storage/forgejo.nix), so from the
      # LAN this needs no tunnel. Same key — already registered in forgejo as
      # "apollo key". Keep the Cloudflare entry for off-LAN access. (2026-09-17)
      "192.168.100.143" = {
        User = "git";
        IdentityFile = "${config.home.homeDirectory}/.ssh/id_apollo";
        IdentitiesOnly = true;
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
    # Linux only: the darwin build pulls an EOL electron. macOS gets the app from Homebrew.
    ++ lib.optionals (pkgs.stdenv.hostPlatform.isLinux && osConfig.profiles.desktop.enable) [
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
