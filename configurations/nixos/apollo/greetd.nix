{ pkgs, ... }:
let
  restart-session = pkgs.writeShellScriptBin "restart-session" ''
    exec ${pkgs.uwsm}/bin/uwsm stop
  '';
in
{
  environment.systemPackages = [ restart-session ];

  services.xremap = {
    enable = true;
    withWlroots = true; # enables app-specific remapping on Hyprland
    serviceMode = "user"; # run as user service so it can detect focused Wayland window
    userName = "jake";
    config = {
      keymap = [
        # Wezterm: Cmd+C/V → Ctrl+Shift+C/V (avoid SIGINT)
        # M-t passthrough: prevent global M-t→C-t from intercepting Alt+T in wezterm
        {
          name = "Wezterm Mac-style";
          application.only = [ "wezterm" ];
          remap = {
            "M-c" = "C-S-c";
            "M-v" = "C-S-v";
            "M-t" = "M-t";
          };
        }
        # Global Mac-style bindings
        {
          name = "Global Mac-style";
          remap = {
            "A-left" = "C-left";
            "A-right" = "C-right";
            "A-BackSpace" = "C-BackSpace";
            "M-c" = "C-c";
            "M-v" = "C-v";
            "M-x" = "C-x";
            "M-a" = "C-a";
            "M-s" = "C-s";
            "M-z" = "C-z";
            "M-t" = "C-t";
            "M-w" = "C-w";
            "M-BackSpace" = "C-BackSpace";
            "M-up" = "C-Home";
            "M-down" = "C-End";
            "M-left" = "Home";
            "M-right" = "End";
          };
        }
      ];
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
