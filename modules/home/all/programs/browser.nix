{ pkgs, ... }:

{
  programs.firefox = {
    enable = true;
    profiles.jake = {
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        vimium
        onepassword-password-manager
        bitwarden
      ];
    };
  };
}
