{
  pkgs,
  lib,
  ...
}:
lib.mkIf (pkgs.system == "x86_64-linux") {
  services.redshift = {
    enable = false;
    provider = "geoclue2";
    longitude = "-71.057083";
    latitude = "42.361145";
    temperature = {
      day = 5500;
      night = 3700;
    };
  };
}
