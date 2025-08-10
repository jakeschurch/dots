{ pkgs, ... }:
{
  home.packages = with pkgs; [
    obs-studio
    nixgl.nixVulkanIntel
    vulkan-tools
    vulkan-validation-layers
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

    (builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts))
  ];
}
