{ flake, ... }:
{
  # Animated desktop pet overlay that reacts to keyboard input. Apollo only —
  # it wants a Wayland compositor with wlr-layer-shell, which is Hyprland here.
  home-manager.sharedModules = [
    flake.inputs.wayland-vpets.homeManagerModules.default
    (
      { pkgs, config, ... }:
      let
        gameConf = pkgs.writeText "bongocat-game.conf" ''
          # Same layout as the keyboard conf, but the controller sprite sheet.
          cat_x_offset=560
          cat_y_offset=3
          cat_height=44
          cat_align=right
          enable_antialiasing=0
          overlay_position=top
          overlay_height=80
          overlay_opacity=0
          layer=overlay
          fps=15
          enable_hand_mapping=1
          idle_sleep_timeout=900
          enable_scheduled_sleep=1
          sleep_begin=23:00
          sleep_end=07:00
          keyboard_device=/dev/input/by-id/usb-Keebio_Quefrency_Rev._4-event-kbd
          keyboard_device=/dev/input/by-id/usb-Logitech_USB_Receiver-event-kbd
          keyboard_device=/dev/input/by-id/usb-Logitech_USB_Receiver-if01-event-mouse
          keyboard_device=/dev/input/by-id/usb-Logitech_USB_Receiver-if03-event-mouse
          keyboard_device=/dev/input/by-id/usb-Razer_Razer_Wolverine_V3_Tournament_Edition_for_PC_LBJ1627_V1.02.02-if01-event-kbd
          keyboard_device=/dev/input/by-id/usb-Razer_Razer_Wolverine_V3_Tournament_Edition_for_PC_LBJ1627_V1.02.02-if01-event-mouse
          keyboard_device=/dev/input/by-id/usb-Razer_Razer_Wolverine_V3_Tournament_Edition_for_PC_LBJ1627_V1.02.02-event-joystick
          keyboard_name=xremap
          hotplug_scan_interval=30
          custom_sprite_sheet_filename=${./bongocat-controller.png}
          animation_name=custom
          custom_idle_frames=1
          custom_writing_frames=3
          custom_sleep_frames=1
          random=0
        '';

        drumsConf = pkgs.writeText "bongocat-drums.conf" ''
          # Drummer cat: same placement, drum-kit sheet, and it listens ONLY
          # to the virtual 'bongobeat' uinput device fed by the beat daemon -
          # so the paws hit on detected beats, not on typing.
          cat_x_offset=560
          cat_y_offset=3
          cat_height=44
          cat_align=right
          enable_antialiasing=0
          overlay_position=top
          overlay_height=80
          overlay_opacity=0
          layer=overlay
          fps=15
          keypress_duration=120
          idle_sleep_timeout=900
          enable_scheduled_sleep=1
          sleep_begin=23:00
          sleep_end=07:00
          hotplug_scan_interval=30
          custom_sprite_sheet_filename=${./bongocat-drums.png}
          animation_name=custom
          custom_idle_frames=1
          custom_writing_frames=3
          custom_sleep_frames=1
          random=0
        '';

        beatPython = pkgs.python3.withPackages (p: [
          p.evdev
          p.aubio-ledfx # aubio fork packaged in nixpkgs; imports as `aubio`
          p.numpy
          p.scipy # band-split filters (kick vs hi-hat)
        ]);

        drumsLaunch = pkgs.writeShellScript "bongocat-drums-launch" ''
          BEATD_PWRECORD=${pkgs.pipewire}/bin/pw-record \
            ${beatPython}/bin/python3 ${./bongocat-beatd.py} &
          # bongocat needs an explicit keyboard_device (keyboard_name alone
          # counts as "no devices specified"), and beatd's uinput node gets a
          # fresh eventN each start — so wait for it, resolve the path, and
          # hand bongocat a runtime copy of the conf pointing at it.
          dev=""
          for _ in $(seq 1 50); do
            n=$(grep -l bongobeat /sys/class/input/event*/device/name 2>/dev/null | head -1)
            if [ -n "$n" ]; then
              dev=/dev/input/$(basename "$(dirname "$(dirname "$n")")")
              break
            fi
            sleep 0.1
          done
          conf="$XDG_RUNTIME_DIR/bongocat-drums.conf"
          # cp from the store keeps mode 444; make the copy writable or the
          # keyboard_device append is silently denied.
          rm -f "$conf"
          cp ${drumsConf} "$conf"
          chmod u+w "$conf"
          [ -n "$dev" ] && printf 'keyboard_device=%s\n' "$dev" >>"$conf"
          exec "$1" --config "$conf"
        '';

        jukebox = pkgs.writeShellScript "bongocat-jukebox" ''
          sctl=/run/current-system/sw/bin/systemctl
          pctl=${pkgs.playerctl}/bin/playerctl
          while true; do
            st=$("$pctl" status 2>/dev/null | head -1)
            if "$sctl" --user -q is-active wayland-bongocat-game.service; then
              : # game cat outranks the drummer
            elif [ "$st" = "Playing" ]; then
              "$sctl" --user -q is-active wayland-bongocat-drums.service \
                || "$sctl" --user start wayland-bongocat-drums.service
            elif "$sctl" --user -q is-active wayland-bongocat-drums.service; then
              "$sctl" --user start wayland-bongocat.service
            fi
            sleep 5
          done
        '';
      in
      {
        # Controller-cat variant for gaming. gamemode start/end hooks (see
        # modules/nixos/steam.nix) swap between this and the normal unit;
        # mutual Conflicts= guarantees only one cat at a time.
        systemd.user.services.wayland-bongocat-game = {
          Unit = {
            Description = "Wayland Bongo Cat Overlay (controller)";
            After = [ "graphical-session.target" ];
            PartOf = [ "graphical-session.target" ];
            Conflicts = [
              "wayland-bongocat.service"
              "wayland-bongocat-drums.service"
            ];
          };
          Service = {
            Type = "exec";
            ExecStart = "${config.programs.wayland-bongocat.package}/bin/bongocat --config ${gameConf}";
            Restart = "on-failure";
            RestartSec = "5s";
          };
        };

        # Drummer cat + its beat daemon in one cgroup: the wrapper backgrounds
        # beatd (uinput 'bongobeat' device fed from the default sink monitor)
        # and execs bongocat; unit stop kills both.
        systemd.user.services.wayland-bongocat-drums = {
          Unit = {
            Description = "Wayland Bongo Cat Overlay (drums, beat-driven)";
            After = [ "graphical-session.target" ];
            PartOf = [ "graphical-session.target" ];
            Conflicts = [
              "wayland-bongocat.service"
              "wayland-bongocat-game.service"
            ];
          };
          Service = {
            Type = "exec";
            ExecStart = "${drumsLaunch} ${config.programs.wayland-bongocat.package}/bin/bongocat";
            Restart = "on-failure";
            RestartSec = "5s";
          };
        };

        # Poller: music playing -> drummer cat; stopped/paused -> keyboard
        # cat; never preempts the game cat. 5s cadence, self-healing.
        systemd.user.services.bongocat-jukebox = {
          Unit = {
            Description = "Swap bongocat variant with music playback";
            After = [ "graphical-session.target" ];
            PartOf = [ "graphical-session.target" ];
          };
          Service = {
            Type = "exec";
            ExecStart = "${jukebox}";
            Restart = "on-failure";
            RestartSec = "5s";
          };
          Install.WantedBy = [ "graphical-session.target" ];
        };

        systemd.user.services.wayland-bongocat.Unit.Conflicts = [
          "wayland-bongocat-game.service"
          "wayland-bongocat-drums.service"
        ];

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
          catXOffset = 560;
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
