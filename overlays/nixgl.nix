{ flake, ... }:

let
  inherit (flake) inputs;
in
inputs.nixGL.overlay
