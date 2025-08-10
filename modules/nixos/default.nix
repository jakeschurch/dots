{ flake, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  home.packages = with self.pkgs; [
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
