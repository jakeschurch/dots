{
  lib,
  pkgs,
  config,
  ...
}:
let
  shellAliases = import ./../config/aliases.nix { inherit pkgs; };
  concatSessionList = builtins.concatStringsSep ":";
in
{
  home.file.bin = {
    source = ../bin;
    recursive = true;
  };

  home = {
    inherit shellAliases;

    extraOutputsToInstall = [
      "doc"
      "info"
      "share"
      "bin"
      "dev"
      "include"
    ];

    sessionPath =
      [
        "${config.home.homeDirectory}/dots/config/nixpkgs"
        "/etc/static/profiles/per-user/${config.home.username}/bin"
        "/sbin"
        "/bin"
        "${config.home.homeDirectory}/bin"
        "${config.home.homeDirectory}/.local/bin"
        "${config.home.homeDirectory}/.cargo/bin"
        "${config.home.homeDirectory}/.nix-profile/bin"
        "${pkgs.statix}/bin"
        "${pkgs.alejandra}/bin"
        "/usr/local/bin"
      ]
      ++ lib.optionals pkgs.stdenv.isDarwin [
        "/run/current-system/sw/bin/"
        "/opt/local/homebrew/bin"
        "/System/Volumes/Data/usr/local/bin"
      ];

    sessionVariables = {
      TERM = "wezterm";
      NIX_PROFILES = config.home.profileDirectory;
      MIX_HOME = "${config.home.homeDirectory}/.cache/.nix-mix";
      HEX_HOME = "${config.home.homeDirectory}/.cache/.nix-hex";
      PAGER = "bat";
      MANGER = "batman";
      HISTSIZE = "50000";
      HISTCONTROL = concatSessionList [
        "ignoredups"
        "ignorespace"
      ];
      NIX_PATH = "nixpkgs=flake:nixpkgs";
      HISTIGNORE = concatSessionList [
        "ls *"
        "history"
        "cd *"
        "z *"
        "rm *"
      ];

      LANG = "en_US.UTF-8";
      LANGUAGE = "en_US.UTF-8";
      LC_ADDRESS = "en_US.UTF-8";
      LC_ALL = "en_US.UTF-8";
      LC_COLLATE = "en_US.UTF-8";
      LC_CTYPE = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MESSAGES = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };
}
