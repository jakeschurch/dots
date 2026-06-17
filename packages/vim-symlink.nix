{
  vimUtils,
  fetchFromGitHub,
  nix-update-script,
}:

vimUtils.buildVimPlugin {
  pname = "vim-symlink";
  version = "0-unstable-2026-06-03";

  src = fetchFromGitHub {
    owner = "aymericbeaumet";
    repo = "vim-symlink";
    rev = "bb468cdb4a6de3df81477e441ec8736446f83674";
    sha256 = "0g6pz708fgl1qzh79jn74pk6b5bc13cnp5vrcj9858g1zq1jyvsr";
  };

  doCheck = false;
  postInstall = "rm -rf $out/test $out/tests $out/spec";

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
}
