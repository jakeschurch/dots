{
  flake,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./all/nix.nix
    ./all/programs/git
    ./all/programs/fish
  ];

  home = {
    stateVersion = "25.05";
    enableNixpkgsReleaseCheck = false;
    username = flake.config.me.username;

    packages = with pkgs; [
      mosh
      ripgrep
      fd
      fzf
      bat
    ];

    sessionVariables = {
      TERM = "xterm-256color";
      LANG = "en_US.UTF-8";
      LC_ALL = "en_US.UTF-8";
    };
  };

  xdg = {
    enable = true;
    dataHome = "${config.home.homeDirectory}/.local/share";
    configHome = "${config.home.homeDirectory}/.config";
    cacheHome = "${config.home.homeDirectory}/.cache";
  };

  programs = {
    home-manager.enable = true;

    tmux.enable = true;

    ssh = {
      enable = true;
      matchBlocks."*" = {
        compression = true;
        forwardAgent = true;
      };
    };
  };
}
