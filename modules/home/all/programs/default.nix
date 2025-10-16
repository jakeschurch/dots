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
    ./eww
    ./fd.nix
    ./git
    ./hammerspoon
    ./i3
    ./k9s
    ./neovim
    ./psql.nix
    ./ripgrep.nix
    ./rofi
    ./scripts
    ./slack.nix
    ./ssh.nix
    ./terragrunt.nix
    ./wezterm
    ./zsh
  ];
}
