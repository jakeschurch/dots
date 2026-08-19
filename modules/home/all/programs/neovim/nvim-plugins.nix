{ pkgs, ... }:
# Auto-imports every plugins/*.nix. Each returns a flat list for one domain,
# mirroring config/lua/domain/<capability>/.
let
  inherit (pkgs) lib;

  domains = lib.attrNames (
    lib.filterAttrs (n: t: t == "regular" && lib.hasSuffix ".nix" n) (builtins.readDir ./plugins)
  );
in
lib.concatMap (name: import (./plugins + "/${name}") { inherit pkgs; }) domains
