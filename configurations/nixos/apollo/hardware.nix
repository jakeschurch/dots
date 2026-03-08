{ config, pkgs, ... }:
{
  boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      # NVIDIA Vulkan support
      vulkan-loader
      vulkan-validation-layers
      vulkan-tools
    ];

    # Also need 32-bit packages for Steam games
    extraPackages32 = with pkgs.pkgsi686Linux; [
      mesa
      vulkan-loader
      libva
    ];
  };

  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    powerManagement.enable = true;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    open = true;

    # Enable the Nvidia settings menu, accessible via `nvidia-settings`.
    nvidiaSettings = true;

    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };

  services.xserver.videoDrivers = [ "nvidia" ];
}
