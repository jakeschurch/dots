{ flake, pkgs, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    self.nixosModules.common
  ];

  home.packages = with pkgs; [
    obs-studio
    nixgl.nixGLIntel
    steam
    rofi
    spotify
    docker
    wmctrl
    xbanish
    playerctl
    xbindkeys
    xautolock
    yubikey-manager
    ethtool
    # xev-1.2.4
  ];
}
