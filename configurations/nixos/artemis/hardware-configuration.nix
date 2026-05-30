# TODO: replace with output of `nixos-generate-config` run on artemis hardware
# Run: nixos-generate-config --show-hardware-config
{ modulesPath, ... }:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
}
