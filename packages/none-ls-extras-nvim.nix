{
  vimUtils,
  fetchFromGitHub,
  nix-update-script,
}:

vimUtils.buildVimPlugin {
  pname = "none-ls-extras-nvim";
  version = "0-unstable-2026-07-17";

  src = fetchFromGitHub {
    owner = "nvimtools";
    repo = "none-ls-extras.nvim";
    rev = "9a8b8a9aeb43382e5aaf49b00b7cfb5d42d32118";
    sha256 = "sha256-YmDhDUqSJPOllXzkyrVUgnshrI5+Kt5Te8tEmnjOAVQ=";
  };

  doCheck = false;
  postInstall = "rm -rf $out/test $out/tests $out/spec";

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
}
