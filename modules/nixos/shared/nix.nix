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

  cachesData = import ../../data/caches.nix;
  # Base cache set every host trusts; hosts running a local ncps pull-through
  # (apollo/darwin) mkForce-override substituters to prepend localhost:8501.
  baseCaches = [
    "nix-community"
    "nixos"
    "hyprland"
    "neovim-nightly"
    "nix-gaming"
  ];
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
      permittedInsecurePackages = [
        "electron-19.1.9"
        "electron-39.8.10"
      ];
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
      substituters = cachesData.urls baseCaches;
      trusted-substituters = cachesData.urls baseCaches;
      trusted-public-keys = cachesData.keys baseCaches;
      extra-platforms =
        if pkgs.stdenv.isDarwin then
          "aarch64-darwin x86_64-darwin"
        else if pkgs.stdenv.hostPlatform.system == "x86_64-linux" then
          "i686-linux" # build true-i686 derivations (steam 32-bit, perl IO-Tty) natively
        else
          "";
    };
  };
}
