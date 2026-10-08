_:

{
  programs.tmux = {
    enable = true;
    mouse = true; # wheel scrolls into copy-mode instead of PgUp/PgDn
    # Also bounds how much of a sidekick.nvim CLI session can be scrolled back.
    historyLimit = 50000;
  };
}
