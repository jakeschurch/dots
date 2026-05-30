{ pkgs, ... }:
{
  boot = {
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "boot.shell_on_fail"
      "udev.log_priority=3"
    ];

    loader = {
      systemd-boot.configurationLimit = 5;
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      timeout = 3;
    };

    kernelPackages = pkgs.linuxPackages_zen;

    kernel.sysctl = {
      "vm.dirty_expire_centisecs" = 300;
      "vm.dirty_ratio" = 10;
      "vm.dirty_background_ratio" = 5;
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-partlabel/disk-swap"; }
  ];
}
