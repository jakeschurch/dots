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

    # Force games to use NVIDIA GPU (not Intel B580)
    extraPackages = with pkgs; [
      gamescope
      mangohud
      libva
      libvdpau-va-gl
    ];
  };

  # Global environment for games to prefer NVIDIA
  environment.sessionVariables = {
    # Force DXVK/VKD3D to use NVIDIA only
    DXVK_FILTER_DEVICE_NAME = "NVIDIA";
    VKD3D_FILTER_DEVICE_NAME = "NVIDIA";

    # PRIME render offload to NVIDIA
    __NV_PRIME_RENDER_OFFLOAD = "1";
    __VK_LAYER_NV_optimus = "NVIDIA_only";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
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
