_: {
  projectRootFile = "flake.nix";
  settings.formatter.deadnix.includes = [
    "*.nix"
    "!./Templates/flake.nix"
  ];
  programs = {
    # lua
    stylua.enable = true;

    shellcheck.enable = true;

    # nix
    alejandra.enable = true;
    deadnix.enable = true;
  };
}
