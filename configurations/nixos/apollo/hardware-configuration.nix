{
  config,
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usbhid"
    "usb_storage"
    "sd_mod"
    "sr_mod"
  ];
  boot.kernelModules = [ "nvidia" ];

  boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];

  boot.blacklistedKernelModules = [ "nouveau" ];

  fileSystems."/old_root" = {
    device = "/dev/disk/by-uuid/90ddca5d-d771-49b7-a5e4-4e8e99da9c80";
    fsType = "ext4";
    options = [
      "defaults"
      "noatime"
    ];
  };

  fileSystems."/data" = {
    device = "/dev/disk/by-uuid/929d1911-3de3-44fe-a943-2ed07cd67135";
    fsType = "ext4";
    options = [
      "defaults"
      "noatime"
    ];
  };

  fileSystems."/old_home" = {
    device = "/dev/disk/by-uuid/ff3faa6a-ead3-4681-aab9-42f55e2697b6";
    fsType = "ext4";
    options = [
      "defaults"
      "noatime"
    ];
  };

  # fileSystems."/boot" = {
  #   device = "/dev/disk/by-uuid/1D07-66D2";
  #   fsType = "vfat";
  #   options = [
  #     "defaults"
  #     "noatime"
  #     "fmask=0022"
  #     "dmask=0022"
  #   ];
  # };

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp5s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp6s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
