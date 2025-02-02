{
  pkgs,
  lib,
  ...
}:
lib.mkIf pkgs.stdenv.isDarwin {
  homebrew = {
    enable = true;
    onActivation = {
      cleanup = "uninstall";
      autoUpdate = false;
      upgrade = false;
    };

    brews = [
      "detect-secrets"
      "gettext"
      "openssl"
      "yajl"
    ];

    taps = [
      "homebrew/services"
    ];

    casks = [
      "arc"
      "around"
      "balenaetcher"
      "caffeine"
      "hammerspoon"
      "notion"
      "notion"
      "postman"
      "raycast"
      "spotify"
      "steam"
      "yubico-authenticator"
      "yubico-yubikey-manager"
    ];
  };
}
