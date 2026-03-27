{ pkgs, ... }:

{
  programs.firefox = {
    enable = true;
    profiles.jake = {
      extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
        vimium
        onepassword-password-manager
        bitwarden
      ];
    };
  };
}
