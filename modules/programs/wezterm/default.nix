_: {
  programs.wezterm = {
    enable = true;
    enableZshIntegration = false;
    extraConfig = builtins.readFile ./wezterm.lua;
  };
}
