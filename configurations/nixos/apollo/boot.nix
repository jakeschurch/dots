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

    # Splash by default; Esc during boot toggles the plymouth details view,
    # which streams full kernel + systemd unit status (verbose settings below).
    consoleLogLevel = 4;
    initrd.verbose = true;
    kernelParams = [
      "splash"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "systemd.show_status=true"
      "rd.systemd.show_status=true"
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
      "nvidia_modeset"
      "nvidia_uvm"
      "nvidia_drm"
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
}
