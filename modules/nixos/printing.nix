{ pkgs, ... }:
{
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      gutenprint
      gutenprintBin
      hplip
      hplipWithPlugin
      brlaser
      brgenml1lpr
      brgenml1cupswrapper
      cnijfilter2
      foomatic-db
      foomatic-db-ppds
      foomatic-db-nonfree
      foomatic-db-nonfree-ppds
    ];
    browsing = true;
    browsedConf = ''
      BrowseDNSSDSubTypes _cups,_print
      BrowseLocalProtocols all
      BrowseRemoteProtocols all
      CreateIPPPrinterQueues All
    '';
  };

  # Network printer discovery
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

  # Scanner support
  hardware.sane = {
    enable = true;
    extraBackends = with pkgs; [
      hplipWithPlugin
      sane-airscan
      epkowa
    ];
  };

  services.ipp-usb.enable = true;

  environment.systemPackages = with pkgs; [
    system-config-printer
    simple-scan
    gscan2pdf
  ];
}
