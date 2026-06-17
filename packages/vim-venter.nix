{
  vimUtils,
  fetchFromGitHub,
  nix-update-script,
}:

vimUtils.buildVimPlugin {
  pname = "vim-venter";
  version = "0.0.2-unstable-2026-04-22";

  src = fetchFromGitHub {
    owner = "jmckiern";
    repo = "vim-venter";
    rev = "558b58d2f50d1bd124a479a19ecaa9cfbbd48849";
    sha256 = "0n0a5kcx17j1lhscfc9p8gx6nk2kxdnrira7wmm3fznm0lm3zdl5";
  };

  doCheck = false;
  postInstall = "rm -rf $out/test $out/tests $out/spec";

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
}
