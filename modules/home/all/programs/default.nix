{
  pkgs,
  lib,
  ...
}:
let
  scripts = import ./scripts {
    inherit pkgs lib;
    inherit (pkgs.lib) mkScript;
  };
in
{
  imports = [
    scripts
    ./browser.nix
    ./fd.nix
    ./fish
    ./git
    ./hammerspoon
    ./hyprland
    ./i3
    ./k9s
    ./krita.nix
    ./neovim
    ./obsidian.nix
    ./psql.nix
    ./ripgrep.nix
    ./scripts
    ./slack.nix
    ./ssh.nix
    ./tablet-calibration.nix
    ./terragrunt.nix
    ./wezterm
    ./zsh
  ];
}
