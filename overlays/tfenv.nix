{ flake, ... }:

let
  inherit (flake) inputs;
in
inputs.tfenv.overlays.default
