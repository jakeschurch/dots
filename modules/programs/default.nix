{
  pkgs,
  mkScript,
  ...
}:
let
  scripts = import ./scripts {
    inherit mkScript;
    inherit (pkgs)
      python3
      asciinema
      asciinema-agg
      lib
      ffmpeg
      coreutils
      mosh
      coreutils-prefixed
      jq
      ;
  };

in
{

  imports = [
    ./zsh
    scripts

    ./neovim
    ./ripgrep.nix

    ./psql.nix
    ./fd.nix
    ./eww
    ./git
    ./hammerspoon
    ./i3
    ./k9s
    ./rofi
    ./slack.nix
    ./ssh.nix
    ./terragrunt.nix
    ./wezterm
  ];
}
