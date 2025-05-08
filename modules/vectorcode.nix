{
  dream2nix,
  fetchFromGitHub,
  pkgs,
  ...
}:

let
  version = "0.6.5";
  repoSrc = fetchFromGitHub {
    owner = "Davidyz";
    repo = "VectorCode";
    tag = version;
    hash = "sha256-yad8ChKEwSy1yFa8v+pGIKBoDxqbvr800wrhyMfedOM=";
  };

  drv = dream2nix.lib.evalModules {
    packageSets.nixpkgs = pkgs;
    modules = [
      {
        name = "vectorcode";
        inherit version;
        src = repoSrc;
      }
    ];
  };
in
drv
