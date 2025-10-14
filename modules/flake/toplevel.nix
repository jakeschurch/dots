# Top-level flake glue to get our configuration working
{ inputs, ... }:
let
  inherit (inputs) self;
in
{
  imports = [
    inputs.nixos-unified.flakeModules.default
    inputs.nixos-unified.flakeModules.autoWire
    inputs.home-manager.flakeModules.home-manager
    inputs.git-hooks-nix.flakeModule
  ];

  perSystem =
    {
      self',
      system,
      lib,
      ...
    }:
    let
      overlays = lib.attrValues self.overlays;
    in
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system overlays;
        config.allowUnfree = true;
      };

      packages = {
        # For 'nix fmt'
        # formatter = pkgs.nixpkgs-fmt;

        # Enables 'nix run' to activate.
        default = self'.packages.activate;
      };
    };
}
