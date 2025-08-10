{ pkgs, lib, ... }:
{
  home.packages = [
    (pkgs.ripgrep.override { withPCRE2 = true; })
  ];

  home.file.".rgignore".text = import ../../../config/ignore.nix { inherit lib; };
}
