{ lib, ... }:
{
  # Mirror of modules/nixos/shared/options.nix so home modules gated on
  # osConfig.profiles.desktop.enable evaluate under nix-darwin too. Every
  # darwin host is a desktop, hence default true (nixos defaults false).
  options.profiles.desktop.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable desktop/graphics features in home modules.";
  };
}
