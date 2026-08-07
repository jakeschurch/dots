# Shared system options, imported by both NixOS and Darwin so home-manager modules
# can read osConfig.profiles.* on either platform.
{ lib, ... }:
{
  options.profiles.desktop.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable desktop/graphics features (Hyprland, Steam, printing, Bitwarden GUI, etc.). Off by default so a host that forgets to set it gets a minimal server, not an accidental desktop.";
  };
}
