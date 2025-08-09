{ inputs, ... }:
{
  imports = [
    inputs.treefmt-nix.flakeModule
  ];

  perSystem =
    { _, ... }:
    {
      treefmt = {
        programs = {
          # lua
          stylua.enable = true;
          shellcheck.enable = true;

          # nix
          nixfmt.enable = true;
          deadnix.enable = true;

          deadnix.includes = [
            "*.nix"
            "!./Templates/flake.nix"
          ];

          # shellcheck.options = [
          #   "-e"
          #   "SC2155" # Declare and assign separately to avoid masking return values.
          #   "-e"
          #   "SC2001" # See if you can use ${variable//search/replace} instead.
          # ];

          # stylua.options = [
          #   "--indent-type"
          #   "Spaces"
          #   "--indent-width"
          #   "2"
          #   "--column-width"
          #   "80"
          # ];
        };
      };
    };
}
