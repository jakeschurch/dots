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

          # Perch the cat "inside" the noctalia bar: overlay anchored to the
          # top edge, sized to the bar band (bar content is y=18..65 with the
          # 64px exclusion zone). Cat draws on the overlay layer, which stacks
          # above the bar's top layer — so it reads as sitting in the bar.
          overlayPosition = "top";
          # overlayHeight is the layer-shell surface the sprite draws inside, so
          # it has to stay above catHeight or the sprite gets clipped.
          # 80 (not 64) so the cat can sit low: y = (overlay-cat)/2 + offset,
          # 18+3=21 → feet at 65 = the bar pill's bottom edge.
          overlayHeight = 80;
          catHeight = 44;
          catAlign = "right";
          # ALIGN_RIGHT math is x = width - cat_width - offset, so POSITIVE
          # pulls the cat left, away from the edge (negative goes off-screen).
          # 320 clears the right-side widget cluster.
          catXOffset = 320;
          catYOffset = 3;

          # Default is /dev/input/event4, which on apollo is the Logitech
          # MOUSE alone — the cat never saw a keypress. by-id paths are stable
          # across re-enumeration; list every keyboard/mouse/pad so it reacts
          # to all of them. xremap grabs the physical keyboards (EVIOCGRAB is
          # exclusive), so its virtual device — matched by name below — is the
          # one that actually emits key events.
          inputDevices = [
            "/dev/input/by-id/usb-Keebio_Quefrency_Rev._4-event-kbd"
            "/dev/input/by-id/usb-Logitech_USB_Receiver-event-kbd"
            "/dev/input/by-id/usb-Logitech_USB_Receiver-if01-event-mouse"
            "/dev/input/by-id/usb-Logitech_USB_Receiver-if03-event-mouse"
            "/dev/input/by-id/usb-Razer_Razer_Wolverine_V3_Tournament_Edition_for_PC_LBJ1627_V1.02.02-if01-event-kbd"
            "/dev/input/by-id/usb-Razer_Razer_Wolverine_V3_Tournament_Edition_for_PC_LBJ1627_V1.02.02-if01-event-mouse"
            "/dev/input/by-id/usb-Razer_Razer_Wolverine_V3_Tournament_Edition_for_PC_LBJ1627_V1.02.02-event-joystick"
          ];
          inputDeviceNames = [ "xremap" ];

          # 60fps leaves ~16ms per animation tick, which reads as a twitch.
          # Upstream's walking example uses 15.
          fps = 15;
          layer = "overlay";
          enableAntialiasing = false; # pixel sprites

          idleSleepTimeout = 900;
          enableScheduledSleep = true;
          sleepBegin = "23:00";
          sleepEnd = "07:00";

          extraConfig = ''
            # Custom sheet: stock bongocat frames composited with a drawn
            # keyboard under the paws (scratch-generated, see git history).
            # Rows: Idle(1) / Writing(3: left,right,both) / Sleep(1).
            # filename must precede animation_name=custom or the parser warns
            custom_sprite_sheet_filename=${./bongocat-keyboard.png}
            animation_name=custom
            custom_idle_frames=1
            custom_writing_frames=3
            custom_sleep_frames=1
            random=0

            # No movement config: cat stays parked in the bar.
          '';
        };
      }
    )
  ];
}
