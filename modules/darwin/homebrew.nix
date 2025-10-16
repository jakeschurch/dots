{
  homebrew = {
    enable = true;
    onActivation = {
      cleanup = "uninstall";
      autoUpdate = true;
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
      "arc"
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
