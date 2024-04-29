{
  pkgs,
  nix-pre-commit-hooks,
  system,
  ...
}:
nix-pre-commit-hooks.lib.${system}.run {
  src = ./.;
  hooks = {
    # nix
    statix-fix = {
      enable = true;
      name = "Statix fix";
      files = "\\.nix$";
      pass_filenames = false;
      entry = "${pkgs.statix}/bin/statix fix --ignore ./Templates/*.nix";
    };

    nix-fmt = {
      enable = true;
      fail_fast = true;
      name = "nix-fmt";
      entry = "nix fmt";
      pass_filenames = true;
    };
  };
}
