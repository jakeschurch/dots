{
  pkgs,
  user,
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
  users.users."${user}".home = "/Users/${user}";

  nix.configureBuildUsers = true;

  documentation.enable = true;
  documentation.doc.enable = true;

  fonts.fontDir.enable = true;
  fonts.fonts = with pkgs; [
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
}
