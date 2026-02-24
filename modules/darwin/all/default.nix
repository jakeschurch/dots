{
  lib,
  pkgs,
  flake,
  ...
}:
{
  nix = {
    distributedBuilds = true;
    channel.enable = false;

    settings = {

      auto-optimise-store = false;
      build-users-group = "nixbld";
      cores = 0;
      experimental-features = "nix-command flakes";
      max-jobs = "auto";
      require-sigs = true;
      sandbox = "relaxed";
      sandbox-fallback = lib.mkForce true;
      substituters = [
        "https://nix-community.cachix.org"
        "https://cache.nixos.org/"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
      trusted-users = [
        "root"
        flake.config.me.username
      ];
    };
    optimise.automatic = true;
    gc.automatic = true;
  };

  ids.gids.nixbld = 350;
  ids.uids.nixbld = 350;

  nix.linux-builder = {
    enable = true;
    ephemeral = true;
    maxJobs = 4;
    config = {
      virtualisation = {
        darwin-builder = {
          diskSize = 60 * 1024; # 60GB for k3s images
          memorySize = 8 * 1024; # 8GB RAM
        };
        cores = 4;
      };
    };
  };

  system = {
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };

    defaults = {
      spaces.spans-displays = false;
      NSGlobalDomain = {
        _HIHideMenuBar = false;
        NSAutomaticWindowAnimationsEnabled = true;
        NSWindowShouldDragOnGesture = true;
      };

      dock = {
        autohide = true;
        orientation = "left";
        showhidden = true;
        mru-spaces = false;
      };

      trackpad = {
        Clicking = true;
        TrackpadThreeFingerDrag = false;
      };

      screencapture.location = "~/Documents/Screenshots";

      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        QuitMenuItem = true;
        FXEnableExtensionChangeWarning = false;
      };
    };

    stateVersion = 6;
  };

  environment = {
    extraOutputsToInstall = [
      "share"
      "man"
      "info"
      "doc"
      "devdoc"
    ];

    pathsToLink = [
      "/share"
      "/bin"
      "/usr/bin"
      "/doc"
      "/etc"
      "/info"
      "/share/doc"
    ];
  };

  documentation = {
    enable = true;
    doc.enable = true;
    man.enable = true;
    info.enable = true;
  };

  fonts.packages = builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);

  # Add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;
}
