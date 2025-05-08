{ pkgs, callPackage, ... }:
{
  home.packages = [
    (pkgs.ripgrep.override { withPCRE2 = true; })
  ];

  home.file.".rgignore".text = callPackage ../../config/ignore.nix { };
}
