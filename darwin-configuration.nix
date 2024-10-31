{
  pkgs,
  user,
  inputs,
  ...
}:
pkgs.lib.mkIf pkgs.stdenv.isDarwin {
  environment.extraOutputsToInstall = [
    "doc"
    "info"
    "devdoc"
  ];
  ids.gids.nixbld = 30000;
  ids.uids.nixbld = 350;

  environment.pathsToLink = [
    "/share/zsh"
    "/share"
    "/bin"
    "/usr/bin"
    "/doc"
    "/etc"
    "/info"
    "/share/doc"
  ];

  nix = {
    linux-builder = {
      enable = true;
      ephemeral = true;
      maxJobs = 10;
      config = {
        virtualisation = {
          darwin-builder = {
            diskSize = 120 * 1024;
            memorySize = 4 * 1024;
          };
          cores = 3;
        };
      };
    };

    distributedBuilds = true;

    configureBuildUsers = true;

    gc.automatic = true;

    registry.nixpkgs.flake = inputs.nixpkgs;
    nixPath = ["nixpkgs=${inputs.nixpkgs}"];
  };

  users.users."${user}".home = "/Users/${user}";

  documentation = {
    enable = true;
    doc.enable = true;
    man.enable = true;
    info.enable = true;
  };

  fonts.packages = with pkgs; [
    (nerdfonts.override {
      fonts = ["FiraCode" "DroidSansMono" "Hack" "JetBrainsMono"];
    })
  ];

  system = {
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };

    defaults = {
      spaces.spans-displays = false;
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
        QuitMenuItem = true;
        FXEnableExtensionChangeWarning = false;
      };
    };
  };

  # Add ability to used TouchID for sudo authentication
  security.pam.enableSudoTouchIdAuth = true;

  # Keep nix-daemon updated.
  services.nix-daemon.enable = true;
  system.stateVersion = 5;
}
