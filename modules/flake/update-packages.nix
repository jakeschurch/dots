{
  perSystem =
    { pkgs, ... }:
    {
      # `nix run .#update-packages` — bump every manually-pinned custom package
      # (rev + hash, and vendorHash for Go modules) via nix-update. Run from the
      # flake root; review the resulting diff before committing.
      packages.update-packages = pkgs.writeShellApplication {
        name = "update-packages";
        runtimeInputs = with pkgs; [
          nix-update
          nix
          git
        ];
        text = ''
          # nix-update copies the dirty working tree into the store to evaluate
          # each flake attr. With the flake eval-cache on, the first bump mutates
          # the tree and every later invocation keeps getting handed the now-stale
          # (GC'd) source path -> "path ... is not valid". Disable it so each call
          # re-copies the current tree.
          export NIX_CONFIG="eval-cache = false"

          # "attr:extra-args" — release-tagged packages take no extra args;
          # the rest track their default branch (no upstream releases).
          targets=(
            "terragrunt-ls:--version=branch"
            "kubectl-jq:"
            "ghlite-nvim:--version=branch"
            "vim-symlink:--version=branch"
            "none-ls-extras-nvim:--version=branch"
            "none-ls-shellcheck-nvim:--version=branch"
            "vim-venter:--version=branch"
            "presenting-nvim:--version=branch"
          )

          fail=0
          for entry in "''${targets[@]}"; do
            attr="''${entry%%:*}"
            args="''${entry#*:}"
            echo ">>> nix-update --flake $attr $args"
            # shellcheck disable=SC2086
            if ! nix-update --flake "$attr" $args; then
              echo "!!! failed to update $attr" >&2
              fail=1
            fi
          done
          exit "$fail"
        '';
      };
    };
}
