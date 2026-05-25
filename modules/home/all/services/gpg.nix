{
  pkgs,
  lib,
  ...
}:
lib.mkIf (pkgs.system == "x86_64-linux") {
  home.packages = with pkgs; [
    gnupg
    keybase
    keybase-gui
  ];

  services.gpg-agent = {
    enable = true;
    enableSshSupport = false;
  };
}
