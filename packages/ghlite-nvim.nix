{
  vimUtils,
  fetchFromGitHub,
  nix-update-script,
}:

vimUtils.buildVimPlugin {
  pname = "ghlite-nvim";
  version = "0-unstable-2026-01-15";

  src = fetchFromGitHub {
    owner = "daliusd";
    repo = "ghlite.nvim";
    rev = "43e12c921554be41a75fe1f7be512881f1bd0a5d";
    sha256 = "15igdilmy5ffjkxbwki2pf0xs3xc5qkbq6vhcx548i8vd2lc57fi";
  };

  doCheck = false;
  postInstall = "rm -rf $out/test $out/tests $out/spec";

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
}
