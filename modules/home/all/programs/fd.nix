{ pkgs, lib, ... }:
{
  xdg.configFile."fd/ignore".text = import ../../../../config/ignore.nix { inherit lib; };

  home.packages = [ pkgs.fd ];
}
