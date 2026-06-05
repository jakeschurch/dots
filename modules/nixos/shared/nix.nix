{
  flake,
  pkgs,
  lib,
  config,
  ...
}:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  sops.secrets.netrc = {
    sopsFile = self + "/secrets/netrc.yaml";
    owner = "root";
    mode = "0400";
    path = "/etc/nix/netrc";
  };

  sops.secrets.github-token = {
    sopsFile = self + "/secrets/netrc.yaml";
    key = "github-token";
    owner = "root";
    mode = "0400";
  };

  system.activationScripts.nix-access-tokens = {
    deps = [ "setupSecrets" ];
    text = ''
      echo "access-tokens = github.com=$(cat ${config.sops.secrets.github-token.path})" > /etc/nix/access-tokens.conf
      chmod 444 /etc/nix/access-tokens.conf
    '';
  };

  nix.settings.netrc-file = config.sops.secrets.netrc.path;
  nix.extraOptions = "!include /etc/nix/access-tokens.conf";

  nixpkgs = {
    config = {
      allowUnfree = true;
      cudaSupport = false;
      allowBroken = true;

      allowUnfreePredicate = pkg: builtins.elem (inputs.nixpkgs.lib.getName pkg) [ "terraform-1.9.6" ];
      permittedInsecurePackages = [ "electron-19.1.9" "electron-39.8.10" ];
    };
    overlays = lib.attrValues self.overlays ++ [
      inputs.nixGL.overlay
    ];
  };

  nix = {
    nixPath = [ "nixpkgs=${flake.inputs.nixpkgs}" ]; # Enables use of `nix-shell -p ...` etc
    registry = {
      nixpkgs.flake = flake.inputs.nixpkgs; # Make `nix shell` etc use pinned nixpkgs
    };

    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };

    settings = {
      fallback = true;
      auto-optimise-store = true;
      cores = 0;
      max-jobs = "auto";
      http-connections = 25;
      max-substitution-jobs = 40;
      sandbox = "relaxed";
      sandbox-fallback = lib.mkForce true;

      trusted-users = [
        "root"
        flake.config.me.username
        "@wheel"
      ];
      experimental-features = [
        "nix-command"
        "flakes"
        "auto-allocate-uids"
      ];
      substituters = [
        "https://nix-community.cachix.org"
        "https://cache.nixos.org/"
        "https://hyprland.cachix.org"
      ];

      trusted-substituters = [
        "https://nix-community.cachix.org"
        "https://cache.nixos.org/"
        "https://hyprland.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
      extra-platforms = lib.mkIf pkgs.stdenv.isDarwin "aarch64-darwin x86_64-darwin";
    };
  };
}
