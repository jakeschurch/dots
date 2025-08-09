{
  pkgs,
  lib,
  ...
}:
lib.mkIf pkgs.stdenv.isLinux {
  home = {
    packages = with pkgs; [ rofi ];

    file.".local/share/rofi/themes".source = ./themes;
    file.".config/rofi/config.rasi".text = ''
      configuration {}
      @theme "rounded-red-dark"
    '';
  };
}
