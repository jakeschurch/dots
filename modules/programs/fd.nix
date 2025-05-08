{ callPackage, pkgs, ... }:
{
  xdg.configFile."fd/ignore".text = callPackage ../../config/ignore.nix { };

  home.packages = [ pkgs.fd ];
}
