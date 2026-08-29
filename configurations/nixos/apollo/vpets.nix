{ flake, ... }:
{
  # Animated desktop pet overlay that reacts to keyboard input. Apollo only —
  # it wants a Wayland compositor with wlr-layer-shell, which is Hyprland here.
  home-manager.sharedModules = [
    flake.inputs.wayland-vpets.homeManagerModules.default
    (
      { pkgs, ... }:
      {
        programs.wayland-bongocat = {
          enable = true;
          autostart = true;

          # Upstream ships every sprite set behind a cmake flag, and all of them
          # except bongocat default to OFF. Without one of these the binary has
          # no pkmn sprites at all and silently falls back:
          #   WARNING: Invalid animation_name 'Pikachu', using 'bongocat'
          #
          # PMD (Mystery Dungeon) rather than plain pkmn: the plain pkmn sheets
          # are 2-frame idle-only (025_pikachu.png is 44x22), so movement has no
          # frames to play and the sprite is necessarily static. PMD sheets are
          # multi-row and animated (0001_bulbasaur.png is 704x476). PMD replaces
          # the pkmn set rather than adding to it.
          package = flake.inputs.wayland-vpets.packages.${pkgs.system}.default.overrideAttrs (old: {
            cmakeFlags = (old.cmakeFlags or [ ]) ++ [
              "-DFEATURE_PMD_EMBEDDED_ASSETS=ON"
            ];
          });

          overlayPosition = "bottom";
          # overlayHeight is the layer-shell surface the sprite draws inside, so
          # it has to stay above catHeight or the sprite gets clipped.
          overlayHeight = 120;
          catHeight = 96;
          catAlign = "right";
          # Offset from the right edge. Has to be >= movement_radius or the
          # sprite spends half its wander clamped against the screen edge.
          catXOffset = 280;

          layer = "overlay";
          enableAntialiasing = false; # pixel sprites

          idleSleepTimeout = 900;
          enableScheduledSleep = true;
          sleepBegin = "23:00";
          sleepEnd = "07:00";

          # Bare species name — the `pkmn:` prefix form was rejected by the parser.
          # animation_name still has to name a real sprite even with random on:
          # it picks the *set* (pkmn) that random then draws from.
          extraConfig = ''
            animation_name=pmd:Pikachu
            random=1
            random_on_reload=1

            # Wander instead of sitting still. radius is px from the anchor
            # point, speed is px travelled per move animation.
            movement_radius=250
            movement_speed=60

            # Sprite advances along its evolution line as uptime accumulates.
            evolution=uptime
          '';
        };
      }
    )
  ];
}
