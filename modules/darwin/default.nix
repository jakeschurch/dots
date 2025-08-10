{
  flake,
  ...
}:
let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    {
      home-manager.backupFileExtension = "nix-bak";
    }
    self.nixosModules.common
    ./homebrew.nix
    ./all
  ];
}
