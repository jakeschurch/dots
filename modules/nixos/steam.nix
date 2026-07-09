{ pkgs, lib, config, ... }:
{
  config = lib.mkIf config.profiles.desktop.enable {
    # bwrap 0.11.0 tests the sandbox by exec'ing `true`; NixOS only links /usr/bin/env by default
    systemd.tmpfiles.rules = [
      "L+ /usr/bin/true - - - - ${pkgs.coreutils}/bin/true"
    ];

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      gamescopeSession.enable = true;

      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
    };

    programs.gamescope = {
      enable = true;
      capSysNice = true;
    };

    environment.sessionVariables = {
      # Force DXVK/VKD3D to use NVIDIA only
      DXVK_FILTER_DEVICE_NAME = "NVIDIA";
      VKD3D_FILTER_DEVICE_NAME = "NVIDIA";

      # pressure-vessel container doesn't have /run/current-system, so nix-ld panics
      # when it tries to read NIX_LD=/run/current-system/.../ld.so inside the container.
      # Use the direct nix store path instead — /nix/store is bind-mounted into the container.
      NIX_LD = lib.mkForce "${pkgs.glibc}/lib/ld-linux-x86-64.so.2";
      NIX_LD_LIBRARY_PATH = lib.mkForce "${pkgs.glibc}/lib:${pkgs.stdenv.cc.cc.lib}/lib";
    };

    environment.systemPackages = with pkgs; [
      mesa-demos
      pkgsi686Linux.mesa-demos # For glxinfo32
      gamescope # Helps with fullscreen/resolution issues
      vulkan-tools # vulkaninfo
    ];

    hardware.steam-hardware.enable = true;
    programs.gamemode = {
      enable = true;
      settings.custom = {
        start = "/run/current-system/sw/bin/pkill -x phonto; /run/current-system/sw/bin/pkill -x quickshell";
        end = "/run/current-system/sw/bin/uwsm app -- phonto --rand; /run/current-system/sw/bin/uwsm app -- noctalia-shell";
      };
    };
  };
}
