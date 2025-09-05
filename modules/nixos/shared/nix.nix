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
  nixpkgs = {
    config = {
      allowUnfree = true;
      cudaSupport = false;
      allowBroken = true;

      allowUnfreePredicate = pkg: builtins.elem (inputs.nixpkgs.lib.getName pkg) [ "terraform-1.9.6" ];
      permittedInsecurePackages = [ "electron-19.1.9" ];
    };
    overlays = lib.attrValues self.overlays ++ [
      inputs.nixGL.overlay
      inputs.tfenv.overlays.default
    ];
  };

  nix = {
    nixPath = [ "nixpkgs=${flake.inputs.nixpkgs}" ]; # Enables use of `nix-shell -p ...` etc
    registry = {
      nixpkgs.flake = flake.inputs.nixpkgs; # Make `nix shell` etc use pinned nixpkgs
    };

    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "auto-allocate-uids"
      ];
      substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
      extra-platforms = lib.mkIf pkgs.stdenv.isDarwin "aarch64-darwin x86_64-darwin";
    };
  };
}
