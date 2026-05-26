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
    };
  };
}
