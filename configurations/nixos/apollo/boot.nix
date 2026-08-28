# apollo-specific boot: plymouth splash, NVIDIA early KMS, VFIO passthrough, EAC.
# Shared core (loader, zen kernel, vm.dirty sysctls, common kernelParams) lives in
# modules/nixos/boot.nix.
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
    # which streams full kernel + systemd unit status. Override the shared quiet
    # defaults to make that view verbose.
    consoleLogLevel = 4;
    initrd.verbose = true;
    # Merges with the shared common params (boot.shell_on_fail, udev.log_priority).
    kernelParams = [
      "splash"
      "systemd.show_status=true"
      "rd.systemd.show_status=true"
      "amd_iommu=on"
      "vfio-pci.ids=8086:e211"
    ];

    # AC-9260 (iwlwifi) defaults to power_scheme=2 (balanced), which parks the radio
    # between frames. On a desktop that never sleeps and carries the k3s control
    # plane over wifi, that showed up as ~60% tx retries and rate collapse to MCS1
    # at -69 dBm. Pin the radio active and disable U-APSD. (2026-08-28)
    extraModprobeConfig = ''
      options iwlmvm power_scheme=1
      options iwlwifi power_save=0 uapsd_disable=3
    '';

    initrd.kernelModules = [
      "nvidia"
      "nvidia_modeset"
      "nvidia_uvm"
      "nvidia_drm"
      "vfio_pci"
      "vfio"
      "vfio_iommu_type1"
    ];

    # Merges with the shared vm.dirty sysctls.
    # Required for EasyAntiCheat Linux module (EAC uses perf_event_open to monitor
    # game processes; paranoid=2 blocks it entirely).
    kernel.sysctl."kernel.perf_event_paranoid" = 1;
  };
}
