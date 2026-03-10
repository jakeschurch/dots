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
    ./i3
    ./k9s
    ./neovim
    ./psql.nix
    ./ripgrep.nix
    ./scripts
    ./slack.nix
    ./ssh.nix
    ./ssh.nix
    ./terragrunt.nix
    ./wezterm
    ./zsh
  ];
}
