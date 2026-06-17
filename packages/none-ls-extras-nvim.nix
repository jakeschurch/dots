{
  vimUtils,
  fetchFromGitHub,
  nix-update-script,
}:

vimUtils.buildVimPlugin {
  pname = "none-ls-extras-nvim";
  version = "0-unstable-2026-06-06";

  src = fetchFromGitHub {
    owner = "nvimtools";
    repo = "none-ls-extras.nvim";
    rev = "27681d797a26f1b4d6119296df42f5204c88a2dc";
    sha256 = "sha256-GZLT8X1eLeSkiV5EN1nOkCQg5nwNATURi/KMj90i40I=";
  };

  doCheck = false;
  postInstall = "rm -rf $out/test $out/tests $out/spec";

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
}
