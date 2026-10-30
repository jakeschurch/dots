{ pkgs, lib, ... }:

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

  home.sessionVariables.BROWSER =
    if pkgs.stdenv.hostPlatform.isLinux then "google-chrome-stable" else "firefox";

  # Linux-only: darwin has no xdg mime database (macOS uses LaunchServices).
  xdg.mimeApps = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    enable = true;
    defaultApplications =
      let
        chrome = "google-chrome.desktop";
      in
      {
        "text/html" = chrome;
        "x-scheme-handler/http" = chrome;
        "x-scheme-handler/https" = chrome;
        "application/xhtml+xml" = chrome;
        # Open directories in PCManFM, not zathura's comic-book handler.
        "inode/directory" = "pcmanfm.desktop";
      };
  };
}
