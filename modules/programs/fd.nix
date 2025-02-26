{ pkgs, ... }:
{
  xdg.configFile."fd/ignore".text = pkgs.callPackage ../../config/ignore.nix { };

  home.packages = with pkgs; [
    fd
  ];
}
