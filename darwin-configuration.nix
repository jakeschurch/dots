{
  pkgs,
  user,
  inputs,
  ...
}:
pkgs.lib.mkIf pkgs.stdenv.isDarwin {
  environment.pathsToLink = [
    "/share/zsh"
    "/share"
    "/bin"
    "/usr/bin"
    "/doc"
    "/etc"
    "/info"
  ];

  nix.linux-builder = {
    enable = true;
    ephemeral = true;
    maxJobs = 4;
    config = {
      virtualisation = {
        darwin-builder = {
          diskSize = 40 * 1024;
          memorySize = 8 * 1024;
        };
        cores = 4;
      };
    };
  };

  nix.distributedBuilds = true;
  users.users."${user}".home = "/Users/${user}";

  nix.configureBuildUsers = true;

  documentation.enable = true;
  documentation.doc.enable = true;

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

  nix.gc.automatic = true;
  nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"];
}
