{ pkgs, ... }:
let
  restart-session = pkgs.writeShellScriptBin "restart-session" ''
    exec ${pkgs.uwsm}/bin/uwsm stop
  '';
in
{
  environment.systemPackages = [ restart-session ];

  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = [ "*" ];
        settings = {
          alt = {
            left = "C-left";
            right = "C-right";
            backspace = "C-backspace";
          };

          meta = {
            backspace = "C-backspace";
            v = "C-v";
            c = "C-c";

            x = "C-x";
            a = "C-a";
            s = "C-s";
            z = "C-z";
            t = "C-t";
            w = "C-w";
            up = "C-home";
            down = "C-end";
            left = "home";
            right = "end";
          };
        };
      };
    };
  };

  environment.variables.HYPRSHOT_DIR = "/home/jake/Pictures/Screenshots";

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.uwsm}/bin/uwsm start hyprland-uwsm.desktop";
        user = "jake";
      };
    };
  };

  # hyprshot mouse daemon // ocr-shot
  # Set up proper permissions for input devices
  users.groups.input = { };
  users.users.jake.extraGroups = [ "input" ];

  services.udev.extraRules = ''
    KERNEL=="event*", GROUP="input", MODE="0660"
    SUBSYSTEM=="input", GROUP="input", MODE="0660"
  '';
}
