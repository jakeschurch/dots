{ config, pkgs, ... }:
{
  powerManagement.cpuFreqGovernor = "performance";

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      # NVIDIA Vulkan support
      vulkan-loader
    ];

    # Also need 32-bit packages for Steam games
    extraPackages32 = with pkgs.pkgsi686Linux; [
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

    # Persistence daemon keeps driver state resident (replaces `nvidia-smi -pm 1`,
    # which is a no-op on the open kernel module).
    nvidiaPersistenced = true;

    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  # Lock GPU to max clocks to prevent ramp-up jitter when CPU-bound.
  # Queries supported clocks at runtime so it works across driver updates.
  # Sleep targets re-run it after suspend/hibernate, which reset the lock.
  systemd.services.nvidia-lock-clocks = {
    description = "Lock NVIDIA GPU to max clocks for gaming";
    after = [
      "multi-user.target"
      "suspend.target"
      "hibernate.target"
      "hybrid-sleep.target"
    ];
    wantedBy = [
      "multi-user.target"
      "suspend.target"
      "hibernate.target"
      "hybrid-sleep.target"
    ];
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
