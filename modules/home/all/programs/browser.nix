{ pkgs, ... }:

{
  programs.firefox = {
    enable = true;
    configPath = ".mozilla/firefox"; # lock legacy path (stateVersion < 26.05)
    profiles.jake = {
      extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
        vimium
        onepassword-password-manager
        bitwarden
      ];
      # Dark, matching the system theme (see ../theme.nix).
      settings = {
        "ui.systemUsesDarkTheme" = 1; # dark browser chrome
        "layout.css.prefers-color-scheme.content-override" = 0; # 0 = dark for sites
      };
    };
  };
}
