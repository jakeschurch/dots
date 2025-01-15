_: {
  projectRootFile = "flake.nix";

  settings.formatter.deadnix.includes = [
    "*.nix"
    "!./Templates/flake.nix"
  ];

  settings.formatter.stylua.options = [
    "--indent-type"
    "Spaces"
    "--indent-width"
    "2"
    "--column-width"
    "80"
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
