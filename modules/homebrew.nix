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
      upgrade = true;
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
      "steam"
      "around"
      "balenaetcher"
      "notion"
      "caffeine"
      "hammerspoon"
      "spotify"
      "yubico-yubikey-manager"
      "yubico-authenticator"
      "notion"
      "postman"
    ];
  };
}
