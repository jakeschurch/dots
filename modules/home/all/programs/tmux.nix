{ ... }:

{
  programs.tmux = {
    enable = true;
    mouse = true; # wheel scrolls into copy-mode instead of PgUp/PgDn
  };
}
