# Shared boot core for all NixOS hosts. Host boot.nix files layer only their
# divergence on top (apollo: plymouth/nvidia/vfio passthrough/verbose;
# artemis: swap). Scalar defaults use mkDefault so hosts can override; list/
# attrset options (kernelParams, kernel.sysctl) merge with host additions.
{ pkgs, lib, ... }:
{
  boot = {
    loader = {
      systemd-boot.enable = true;
      systemd-boot.configurationLimit = 5;
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      timeout = 3;
    };

    kernelPackages = pkgs.linuxPackages_zen;

    # Quiet-ish console by default; a verbose host (apollo's plymouth details
    # view) overrides these.
    consoleLogLevel = lib.mkDefault 3;
    initrd.verbose = lib.mkDefault false;
    kernelParams = [
      "boot.shell_on_fail"
      "udev.log_priority=3"
    ];

    # More aggressive fsync/flush to bound the corruption window on unclean power loss.
    kernel.sysctl = {
      "vm.dirty_expire_centisecs" = 300; # Expire dirty pages faster
      "vm.dirty_ratio" = 10; # Reduce dirty page buffer
      "vm.dirty_background_ratio" = 5;
    };
  };
}
