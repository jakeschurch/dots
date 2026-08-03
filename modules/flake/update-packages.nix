{
  perSystem =
    { pkgs, ... }:
    let
      inherit (pkgs) lib;

      # Custom packages live one-per-file under packages/; the overlay exposes
      # each as pkgs.<basename>. Auto-discover them so no target list is kept by
      # hand here.
      names = map (lib.removeSuffix ".nix") (
        builtins.attrNames (
          lib.filterAttrs (n: t: t == "regular" && lib.hasSuffix ".nix" n) (
            builtins.readDir ../../packages
          )
        )
      );

      # Only packages that opt in via passthru.updateScript get bumped. Each
      # package's own `nix-update-script { extraArgs = ... }` is the single
      # source of truth for its args (--version=branch for branch-tracked
      # plugins, nothing for release-tagged ones); we read those back out here
      # instead of duplicating them.
      updatable = builtins.filter (n: (pkgs.${n} or null) != null && pkgs.${n} ? updateScript) names;

      # nix-update-script evals to [ <nix-update-bin> <arg>... ]; drop arg0 and
      # retarget at the flake attr.
      updateArgs =
        n:
        let
          s = pkgs.${n}.updateScript;
        in
        builtins.tail (if builtins.isList s then s else s.command);

      invocation = n: lib.escapeShellArgs ([ "nix-update" "--flake" n ] ++ updateArgs n);
    in
    {
      # `nix run .#update-packages` — bump every custom package under packages/
      # (rev + hash, and vendorHash for Go modules) via nix-update. The targets
      # and their args are derived from the package set at eval time, so adding a
      # package under packages/ with a passthru.updateScript is all it takes.
      # Run from the flake root; review the resulting diff before committing.
      packages.update-packages = pkgs.writeShellApplication {
        name = "update-packages";
        runtimeInputs = with pkgs; [
          nix-update
          nix
          jq
          git
        ];
        text = ''
          # nix-update copies the dirty working tree into the store to evaluate
          # each flake attr. With the flake eval-cache on, the first bump mutates
          # the tree and every later invocation keeps getting handed the now-stale
          # (GC'd) source path -> "path ... is not valid". Disable it so each call
          # re-copies the current tree.
          export NIX_CONFIG="eval-cache = false"

          # Each bump dirties the tree -> new flake snapshot. nix-update's eval
          # does getFlake on that snapshot's store path, which needs a second
          # store copy that nix won't materialize on its own -> "path ... is not
          # valid". Materialize it up front before every invocation.
          warm() {
            local p
            p=$(nix flake metadata --json | jq -r .path)
            nix eval --impure --expr "builtins.getFlake \"$p\"" --apply 'f: f.narHash' > /dev/null
          }

          fail=0
          ${lib.concatMapStringsSep "\n" (n: ''
            warm
            echo ">>> ${invocation n}"
            ${invocation n} || { echo "!!! failed to update ${n}" >&2; fail=1; }
          '') updatable}
          exit "$fail"
        '';
      };
    };
}
