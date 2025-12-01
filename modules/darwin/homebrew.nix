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
    ];

    taps = [
      "homebrew/services"
    ];

    casks = [
      "balenaetcher"
      "caffeine"
      "moonlight"
      "wifiman"
      "google-chrome"
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
