{
  flake,
  pkgs,
  lib,
  ...
}:
let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    ./homebrew.nix
    self.nixosModules.common
    self.homeModules.darwin-only
  ];

  nix = {
    distributedBuilds = true;
    channel.enable = false;
  };

  ids.gids.nixbld = 350;
  ids.uids.nixbld = 350;

  nix.linux-builder = {
    enable = false;
    ephemeral = false;
    config = {
      virtualisation = {
        darwin-builder = {
          diskSize = 40 * 1024;
          memorySize = 2 * 1024;
        };
        cores = 1;
      };
    };
  };

  system = {
    primaryUser = flake.config.me.username;

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

  users = {
    # REVIEW: temporary fix for darwin
    knownUsers = lib.mkForce [ ];
    knownGroups = lib.mkForce [ ];

    users."${flake.config.me.username}".home = "/Users/${flake.config.me.username}";
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

  home-manager.backupFileExtension = "bak";

  documentation = {
    enable = true;
    doc.enable = true;
    man.enable = true;
    info.enable = true;
  };

  fonts.packages = builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);

  # Add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;
  security.sudo.extraConfig = "${flake.config.me.username}    ALL = (ALL) NOPASSWD: ALL";
}
