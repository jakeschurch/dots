{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    krita
  ];

  # Pressure sensitivity auto-works via libinput/Wayland
  # Configure brushes + UI in Krita itself
}
