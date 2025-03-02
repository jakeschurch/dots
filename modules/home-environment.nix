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
      HISTSIZE = "50000";
      HISTCONTROL = concatSessionList [
        "ignoredups"
        "ignorespace"
      ];
      NIX_PATH = "nixpkgs=flake:nixpkgs";

      NIX_CONFIG = ''
        extra-experimental-features = nix-command flakes auto-allocate-uids pipe-operator repl-automation ca-derivations
        experimental-features = nix-command flakes auto-allocate-uids pipe-operator repl-automation
        accept-flake-config = true
        allow-dirty = true
        allowed-users = root jake @wheel
        always-allow-substitutes = true
        auto-optimise-store = true
        builders-use-substitutes = true
        cores = 0
        download-attempts = 3
        fsync-metadata = false
        http-connections = 0
        keep-derivations = true
        keep-outputs = true
        max-jobs = auto
        max-substitution-jobs = 0
        preallocate-contents = true
        pure-eval = false
        substitute = true
        substituters = https://nix-community.cachix.org?priority=1 https://cache.lix.systems?priority=2 https://cache.nixos.org?priority=3
        trusted-public-keys = cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=
        trusted-substituters = https://nix-community.cachix.org?priority=1 https://cache.lix.systems?priority=2 https://cache.nixos.org?priority=3
        trusted-users = root jake
        warn-dirty = false
      '';

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
