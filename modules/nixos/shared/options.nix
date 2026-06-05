{ lib, ... }:
{
  options.profiles.desktop.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable desktop/graphics features (Hyprland, Steam, printing, Bitwarden GUI, etc.)";
  };
}
