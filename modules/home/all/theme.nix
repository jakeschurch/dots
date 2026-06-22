# Dark theme, system-wide across environments.
#   Linux : GTK (adw-gtk3-dark, covers gtk3 + libadwaita/gtk4), Qt (adwaita-dark),
#           and dconf color-scheme=prefer-dark so portals/Firefox/electron follow.
#   macOS : NSGlobalDomain AppleInterfaceStyle=Dark via home-manager darwin defaults.
{
  pkgs,
  lib,
  osConfig,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) isLinux isDarwin;
in
lib.mkMerge [
  (lib.mkIf (isLinux && osConfig.profiles.desktop.enable) {
    gtk = {
      enable = true;
      theme = {
        name = "adw-gtk3-dark";
        package = pkgs.adw-gtk3;
      };
      iconTheme = {
        name = "Adwaita";
        package = pkgs.adwaita-icon-theme;
      };
      gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
      gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
    };

    qt = {
      enable = true;
      platformTheme.name = "adwaita";
      style = {
        name = "adwaita-dark";
        package = pkgs.adwaita-qt;
      };
    };

    # Makes XDG desktop portal report a dark preference; Firefox (with
    # widget.use-xdg-desktop-portal), GTK apps and electron honour it.
    dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
  })

  (lib.mkIf isDarwin {
    targets.darwin.defaults.NSGlobalDomain.AppleInterfaceStyle = "Dark";
  })
]
