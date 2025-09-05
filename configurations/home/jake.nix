{
  flake,
  pkgs,
  ...
}:
let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    self.homeModules.default
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    # set the Hyprland and XDPH packages to null to use the ones from the NixOS module
    package = null;
    portalPackage = null;

    plugins = [
      flake.inputs.hypr-dynamic-cursors.packages.${pkgs.system}.hypr-dynamic-cursors
      flake.inputs.hyprland-plugins.packages.${pkgs.system}.hyprbars
      flake.inputs.hy3.packages.${pkgs.system}.hy3
    ];
  };
}
