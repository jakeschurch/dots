_: {
  services.tlp.enable = true;
  xdg.config.".screenlayout" = {
    recursive = true;
    source = ./screenlayout;
  };

  home = {
    homeDirectory = "/home/jake";
    username = "jake";

    file = {
      ".xbindkeysrc".text = ''
        "playerctl -p spotify play-pause"
        XF86AudioPlay

        "playerctl -p spotify next"
        XF86AudioNext

        "playerctl -p spotify previous"
        XF86AudioPrev
      '';

      ".xinitrc".text = ''
        [[ -f ~/.Xresources ]] && xrdb -merge -I $HOME ~/.Xresources
      '';

      ".Xresources".text = ''
        XTerm*kitty: xterm-256color

        ! hard contrast: *background: #1d2021
        *background: #282828
        ! soft contrast: *background: #32302f
        *foreground: #ebdbb2
        ! Black + DarkGrey
        *color0:  #282828
        *color8:  #928374
        ! DarkRed + Red
        *color1:  #cc241d
        *color9:  #fb4934
        ! DarkGreen + Green
        *color2:  #98971a
        *color10: #b8bb26
        ! DarkYellow + Yellow
        *color3:  #d79921
        *color11: #fabd2f
        ! DarkBlue + Blue
        *color4:  #458588
        *color12: #83a598
        ! DarkMagenta + Magenta
        *color5:  #b16286
        *color13: #d3869b
        ! DarkCyan + Cyan
        *color6:  #689d6a
        *color14: #8ec07c
        ! LightGrey + White
        *color7:  #a89984
        *color15: #ebdbb2
      '';
    };
  };

  targets.genericLinux.enable = true;

  services.cron = {
    enable = true;
    systemCronJobs = [
      # run daily at 12, cleans up nix store
      "0 12 * * * jake nix-collect-garbage && nix store optimise"
    ];
  };
}
