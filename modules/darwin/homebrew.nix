{
  homebrew = {
    enable = true;
    onActivation = {
      # Should be cleanup = "uninstall", but nix-darwin's homebrew module still
      # emits the flag as `--force-cleanup` (modules/homebrew.nix:196), which
      # Homebrew 4.x rejects: "Error: invalid option: --force-cleanup". Its own
      # docs already say `--cleanup`, so pass that by hand until upstream
      # catches up. Same behavior: --cleanup implies `cleanup --force`.
      cleanup = "none";
      extraFlags = [ "--cleanup" ];
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
      # The nixpkgs darwin build pulls an EOL electron, so home/all/programs/ssh.nix
      # gates bitwarden-desktop to Linux and macOS takes the cask instead.
      "bitwarden"
      "caffeine"
      "moonlight"
      "wifiman"
      "google-chrome"
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
