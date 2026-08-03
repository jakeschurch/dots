{
  vimUtils,
  fetchFromGitHub,
  nix-update-script,
}:

vimUtils.buildVimPlugin {
  pname = "presenting-nvim";
  version = "0.1.0-unstable-2026-07-06";

  src = fetchFromGitHub {
    owner = "sotte";
    repo = "presenting.nvim";
    rev = "aa32b58b86fb1467922396f058cd69b1dc85b6e6";
    sha256 = "sha256-nAOKUW01KyC5kCP86s0KUsNPfb9wWngDNH3KWvKBwo8=";
  };

  doCheck = false;
  postInstall = "rm -rf $out/test $out/tests $out/spec";

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
}
