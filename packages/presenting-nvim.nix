{
  vimUtils,
  fetchFromGitHub,
  nix-update-script,
}:

vimUtils.buildVimPlugin {
  pname = "presenting-nvim";
  version = "0.1.0-unstable-2025-09-27";

  src = fetchFromGitHub {
    owner = "sotte";
    repo = "presenting.nvim";
    rev = "e78245995a09233e243bf48169b2f00dc76341f7";
    sha256 = "0ad9gp1k262ghwa18kp2vnp729a02z9r38iqg124ai0j8cb8vx23";
  };

  doCheck = false;
  postInstall = "rm -rf $out/test $out/tests $out/spec";

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
}
