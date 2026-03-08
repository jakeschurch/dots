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
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-partlabel/disk-swap"; }
  ];
}
