{ pkgs, ... }:

{
  services.printing = {
    enable = true;

    drivers = with pkgs; [
      gutenprint
      hplipWithPlugin
      brlaser
      splix
      cnijfilter2
    ];
  };

  # Network printer discovery (AirPrint / IPP)
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;

    publish = {
      enable = true;
      addresses = true;
      userServices = true;
    };
  };

  # Scanner support (SANE)
  hardware.sane = {
    enable = true;

    extraBackends = with pkgs; [
      sane-airscan
      hplipWithPlugin
    ];
  };

  # IPP-over-USB printers (modern USB printers)
  services.ipp-usb.enable = true;

  # Fix for cups-browsed flakiness (don’t over-force restart)
  systemd.services.cups-browsed = {
    serviceConfig.Restart = "on-failure";
  };

  environment.systemPackages = with pkgs; [
    system-config-printer
    simple-scan
  ];
}
