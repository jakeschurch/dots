{ config, pkgs, ... }:
{
  boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];

  powerManagement.cpuFreqGovernor = "performance";

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      # NVIDIA Vulkan support
      vulkan-loader
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

  systemd.services.nvidia-power-limit = {
    description = "Set NVIDIA RTX 4080 power limit to 385W";
    after = [ "multi-user.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${config.hardware.nvidia.package.bin}/bin/nvidia-smi -pl 385
      ${config.hardware.nvidia.package.bin}/bin/nvidia-smi -pm 1
    '';
  };

  # Lock GPU to max clocks to prevent ramp-up jitter when CPU-bound.
  # Queries supported clocks at runtime so it works across driver updates.
  systemd.services.nvidia-lock-clocks = {
    description = "Lock NVIDIA GPU to max clocks for gaming";
    after = [
      "multi-user.target"
      "nvidia-power-limit.service"
    ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      smi="${config.hardware.nvidia.package.bin}/bin/nvidia-smi"
      MAX_GFX=$($smi --query-supported-clocks=graphics --format=csv,noheader | head -1 | tr -d ' MHz')
      $smi -lgc "$MAX_GFX"
    '';
  };
}
