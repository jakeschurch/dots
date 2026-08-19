{ flake, ... }:
{
  # Animated desktop pet overlay that reacts to keyboard input. Apollo only —
  # it wants a Wayland compositor with wlr-layer-shell, which is Hyprland here.
  home-manager.sharedModules = [
    flake.inputs.wayland-vpets.homeManagerModules.default
    {
      programs.wayland-bongocat = {
        enable = true;
        autostart = true;

        overlayPosition = "top";
        overlayHeight = 60;
        catHeight = 48;
        catAlign = "right";
        catXOffset = 120;

        layer = "overlay";
        enableAntialiasing = false; # pixel sprites

        idleSleepTimeout = 300;
        enableScheduledSleep = true;
        sleepBegin = "23:00";
        sleepEnd = "07:00";

        # animation_name selects the sprite set; `random` picks a different
        # member of that set on each reload. See assets/pkmn upstream.
        extraConfig = ''
          animation_name=pkmn:Pikachu
          random=1
          random_on_reload=1
        '';
      };
    }
  ];
}
