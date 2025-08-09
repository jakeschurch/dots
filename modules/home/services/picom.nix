{
  pkgs,
  lib,
  ...
}:
lib.mkIf (pkgs.system == "x86_64-linux") {
  services.picom = {
    enable = true;
    backend = "glx";
    vSync = true;
    fade = true;
    fadeDelta = 5;
    fadeSteps = [
      0.03
      0.03
    ];
    wintypes = {
      dock = {
        shadow = false;
      };
      dnd = {
        shadow = false;
      };
      popup_menu = {
        opacity = 1.0;
      };
      dropdown_menu = {
        opacity = 1.0;
      };
    };
    opacityRules = [
      "100:class_g = 'rofi'"
    ];
  };
}
