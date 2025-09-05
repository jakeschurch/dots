{ flake, pkgs, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  services.displayManager.ly = {
    enable = true;
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    # make sure to also set the portal package, so that they are in sync
    portalPackage =
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };

  environment.variables.NIXOS_OZONE_WL = "1";

  imports = [
    self.nixosModules.default
    inputs.disko.nixosModules.disko
    ./configuration.nix
    ./disko-config.nix
  ];
}
