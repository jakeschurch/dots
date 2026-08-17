{
  homebrew = {
    enable = true;
    onActivation = {
      cleanup = "none";
      extraFlags = [ "--cleanup" ];
      autoUpdate = false;
      upgrade = false;
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
      # The nixpkgs darwin build pulls an EOL electron, so home/all/programs/ssh.nix
      # gates bitwarden-desktop to Linux and macOS takes the cask instead.
      "bitwarden"
      "caffeine"
      # "moonlight"
      "wifiman"
      "google-chrome"
      "notion"
      "postman"
      "raycast"
      "spotify"
      # "steam"
      "yubico-authenticator"
      "yubico-yubikey-manager"
    ];
  };
}
