{
  pkgs,
  lib,
  user,
  ...
}:
lib.mkIf pkgs.stdenv.isDarwin {
  ids.gids.nixbld = 350;
  ids.uids.nixbld = 350;

  system = {
    primaryUser = user;

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

    stateVersion = 5;
  };

  # REVIEW: temporary fix for darwin
  users.knownUsers = lib.mkForce [ ];
  users.knownGroups = lib.mkForce [ ];

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

  home-manager.backupFileExtension = "bak";

  users.users."${user}".home = "/Users/${user}";

  documentation = {
    enable = true;
    doc.enable = true;
    man.enable = true;
    info.enable = true;
  };

  fonts.packages = builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);

  # Add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;
  security.sudo.extraConfig = "jake    ALL = (ALL) NOPASSWD: ALL";
}
