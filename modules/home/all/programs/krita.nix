{
  pkgs,
  lib,
  ...
}:
{
  # nixpkgs krita is Linux-only; on macOS install the official build separately.
  home.packages = lib.optionals pkgs.stdenv.isLinux [ pkgs.krita ];

  # Pressure sensitivity auto-works via libinput/Wayland
  # Configure brushes + UI in Krita itself
}
