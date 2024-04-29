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
      "tfenv"
      "gettext"
      "openssl"
      "yajl"
    ];

    taps = [
      "homebrew/cask-drivers"
      "homebrew/services"
    ];

    casks = [
      "balenaetcher"
      "caffeine"
      "hammerspoon"
      "spotify"
      "yubico-yubikey-manager"
      "yubico-authenticator"
    ];
  };
}
