{ flake, ... }:
{
  # Animated desktop pet overlay that reacts to keyboard input. Apollo only —
  # it wants a Wayland compositor with wlr-layer-shell, which is Hyprland here.
  home-manager.sharedModules = [
    flake.inputs.wayland-vpets.homeManagerModules.default
    (
      {
        pkgs,
        config,
        lib,
        ...
      }:
      let
        # Keep the three variants in the same layer-shell "seat".  Sprite
        # sheets differ, but their geometry must not or swapping looks like a
        # jump in the bar.
        catLayout = ''
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
          idle_sleep_timeout=900
          enable_scheduled_sleep=1
          sleep_begin=23:00
          sleep_end=07:00
          hotplug_scan_interval=30
        '';

        gameConf = pkgs.writeText "bongocat-game.conf" ''
          # Same layout as the keyboard conf, but the controller sprite sheet.
          ${catLayout}
          enable_hand_mapping=1
          # Game mode must not read keyboard or mouse devices: Bongo Cat's
          # direct evdev access can conflict with xremap and interrupt typing.
          keyboard_device=/dev/input/by-id/usb-Razer_Razer_Wolverine_V3_Tournament_Edition_for_PC_LBJ1627_V1.02.02-event-joystick
          custom_sprite_sheet_filename=${./bongocat-controller.png}
          animation_name=custom
          custom_idle_frames=1
          custom_writing_frames=3
          custom_sleep_frames=1
          random=0
        '';

        drumsConf = pkgs.writeText "bongocat-drums.conf" ''
          # Drummer cat: same placement, drum-kit sheet, and it listens ONLY
          # to the virtual 'bongobeat' uinput device fed by the tempo daemon -
          # so each beat-grid pulse plays the complete drum motion.
          ${catLayout}
          animation_speed=50
          keypress_duration=150
          custom_sprite_sheet_filename=${./bongocat-drums.png}
          animation_name=custom
          custom_idle_frames=1
          custom_writing_frames=3
          custom_sleep_frames=1
          random=0
        '';

        beatd =
          pkgs.runCommand "bongocat-beatd"
            {
              nativeBuildInputs = [
                pkgs.rustc
                pkgs.stdenv.cc
              ];
            }
            ''
              mkdir -p "$out/bin"
              rustc -C opt-level=3 -C strip=symbols ${./bongocat-beatd.rs} -o "$out/bin/bongocat-beatd"
            '';

        drumsLaunch = pkgs.writeShellScript "bongocat-drums-launch" ''
          BEATD_PWRECORD=${pkgs.pipewire}/bin/pw-record \
            ${beatd}/bin/bongocat-beatd &
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
            sleep 0.05
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

        # The selector is the only code allowed to choose a cat service.
        # A game flag temporarily takes precedence over MPRIS. flock makes
        # simultaneous GameMode and player events deterministic.
        bongocatMode = pkgs.writeShellScriptBin "bongocat-mode" ''
          sctl=/run/current-system/sw/bin/systemctl
          pctl=${pkgs.playerctl}/bin/playerctl
          state_dir="''${XDG_RUNTIME_DIR:?XDG_RUNTIME_DIR is required}"
          game="$state_dir/bongocat-game-active"
          pid_file="$state_dir/bongocat.pid"
          exec 9>"$state_dir/bongocat-mode.lock"
          ${pkgs.util-linux}/bin/flock -x 9

          select_mode() {
            if [ -e "$game" ]; then
              wanted=controller
            else
              # playerctl's default player is arbitrary.  Music mode belongs
              # to any actively playing MPRIS player, not whichever player
              # happens to be listed first.
              "$pctl" --all-players status 2>/dev/null | grep -qx Playing && wanted=drums || wanted=keyboard
            fi
            case "$wanted" in
              keyboard) unit=wayland-bongocat.service ;;
              drums) unit=wayland-bongocat-drums.service ;;
              controller) unit=wayland-bongocat-game.service ;;
              *) exit 2 ;;
            esac
            "$sctl" --user -q is-active "$unit" && return

            # Conflicts= schedules the stop and start together.  Bongo Cat
            # owns a single runtime PID file, though, so that brief overlap
            # can leave two input readers alive or make the new variant fail
            # to start.  Finish the old process' cleanup before launching the
            # next one.
            for other in \
              wayland-bongocat.service \
              wayland-bongocat-drums.service \
              wayland-bongocat-game.service; do
              [ "$other" = "$unit" ] || "$sctl" --user stop "$other"
            done
            attempt=0
            while [ -e "$pid_file" ] && [ "$attempt" -lt 40 ]; do
              sleep 0.05
              attempt=$((attempt + 1))
            done
            [ ! -e "$pid_file" ] || exit 1
            "$sctl" --user start "$unit"
          }

          case "''${1:-reconcile}" in
            game-start) touch "$game" ;;
            game-end) rm -f "$game" ;;
            reconcile) ;;
            *) exit 2 ;;
          esac
          select_mode
        '';

        # playerctl --follow blocks until an MPRIS status changes, so normal
        # playback produces no polling.  If no player exists it exits; retry
        # slowly so a newly started player is still picked up.
        jukebox = pkgs.writeShellScript "bongocat-jukebox" ''
          mode=${bongocatMode}/bin/bongocat-mode
          pctl=${pkgs.playerctl}/bin/playerctl
          "$mode" reconcile
          while true; do
          "$pctl" --all-players --follow status 2>/dev/null | while IFS= read -r _; do
              "$mode" reconcile
            done
            sleep 5
          done
        '';

        gameModeService = command: {
          Unit = {
            Description = "Set Bongo Cat game state (${command})";
            After = [ "graphical-session.target" ];
          };
          Service = {
            Type = "oneshot";
            ExecStart = "${bongocatMode}/bin/bongocat-mode ${command}";
          };
        };
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
            RestartSec = "1s";
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
            RestartSec = "1s";
            Environment = [
              "BEATD_THRESHOLD=0.3"
              "BEATD_ADAPTIVE_THRESHOLD=1"
              "BEATD_TARGET_RMS=0.10"
              "BEATD_MIN_THRESHOLD=0.15"
              "BEATD_MAX_THRESHOLD=0.80"
              # pw-record defaults to 100ms; use a 256-sample capture quantum
              # so detected hits reach the cat close to the audible transient.
              "BEATD_LATENCY=256"
            ];
          };
        };

        # MPRIS event listener: playing -> drummer and all other states ->
        # keyboard, unless the selector sees an active game.
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
            RestartSec = "1s";
          };
          Install.WantedBy = [ "graphical-session.target" ];
        };

        # One-shot entry points keep GameMode out of selector internals.
        systemd.user.services.bongocat-game-start = gameModeService "game-start";
        systemd.user.services.bongocat-game-end = gameModeService "game-end";

        # Module default is 5s; a crash during a swap race leaves the screen
        # catless that long. 1s recovery.
        systemd.user.services.wayland-bongocat.Service.RestartSec = lib.mkForce "1s";
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
          package =
            flake.inputs.wayland-vpets.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs
              (old: {
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
          # 560 clears the right-side widget cluster.
          catXOffset = 560;
          catYOffset = 3;

          # Never open physical input nodes.  Bongo Cat's evdev reader can
          # compete with xremap and make the desktop unable to type.  Keyboard
          # cat stays a passive overlay; drummer and controller have their own
          # virtual beat and gamepad-only inputs above.
          inputDevices = [ ];
          inputDeviceNames = [ ];

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
