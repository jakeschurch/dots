{
  pkgs,
  lib,
  ...
}:
{
  # Linux-only: krita is not packaged for darwin.
  home.packages = lib.optionals pkgs.stdenv.isLinux [ pkgs.krita ];

  # Pressure sensitivity auto-works via libinput/Wayland
  # Configure brushes + UI in Krita itself
}
