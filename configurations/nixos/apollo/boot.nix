{ pkgs, ... }:
{
  boot = {
    plymouth = {
      enable = true;
      theme = "lone";
      themePackages = with pkgs; [
        # By default we would install all themes
        (adi1090x-plymouth-themes.override {
          selected_themes = [ "lone" ];
        })
      ];
    };

    # Enable "Silent boot"
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "splash"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
      "amd_iommu=on"
      "vfio-pci.ids=8086:e211"
    ];

    loader = {
      # Use the systemd-boot EFI boot loader.
      systemd-boot.configurationLimit = 5;
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      timeout = 3;
    };

    initrd.kernelModules = [
      "nvidia"
      "vfio_pci"
      "vfio"
      "vfio_iommu_type1"
    ];

    kernelPackages = pkgs.linuxPackages_zen;

    # More aggressive fsync/flush to prevent corruption
    kernel.sysctl = {
      "vm.dirty_expire_centisecs" = 300; # Expire dirty pages faster
      "vm.dirty_ratio" = 10; # Reduce dirty page buffer
      "vm.dirty_background_ratio" = 5;

      # Required for EasyAntiCheat Linux module (EAC uses perf_event_open
      # to monitor game processes; paranoid=2 blocks it entirely).
      "kernel.perf_event_paranoid" = 1;
    };
  };

  # NOTE: the active swap (disk-main-swap, nvme0n1p2/128G) is declared by
  # disko-config.nix. The old second swap on `disk-swap` (the reclaimed 860 EVO)
  # is gone — that disk is now the apollovg LVM mayastor PV — so the stale
  # swapDevices entry left a dead dependency-failed .swap unit at every boot.
}
