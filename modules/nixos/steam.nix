{ pkgs, ... }:
{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    gamescopeSession.enable = true;

    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };

  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  # Global environment for games to prefer NVIDIA
  environment.sessionVariables = {
    # Force DXVK/VKD3D to use NVIDIA only
    DXVK_FILTER_DEVICE_NAME = "NVIDIA";
    VKD3D_FILTER_DEVICE_NAME = "NVIDIA";
  };

  environment.systemPackages = with pkgs; [
    mesa-demos
    pkgsi686Linux.mesa-demos # For glxinfo32
    gamescope # Helps with fullscreen/resolution issues
    vulkan-tools # vulkaninfo
  ];

  hardware.steam-hardware.enable = true;
  programs.gamemode.enable = true;
}
