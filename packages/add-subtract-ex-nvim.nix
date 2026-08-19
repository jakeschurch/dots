{
  vimUtils,
  fetchFromGitHub,
  nix-update-script,
}:

vimUtils.buildVimPlugin {
  pname = "add-subtract-ex-nvim";
  version = "0-unstable-2026-08-14";

  src = fetchFromGitHub {
    owner = "DRoma82";
    repo = "add-subtract-ex.nvim";
    rev = "6866573b2c75748d60c04f0a024b17c5edc114b3";
    hash = "sha256-n7sU5Q+vmyHeOFxL/I6CEZFSTTRUqdTk9R28d/EJUVY=";
  };

  doCheck = false;
  postInstall = "rm -rf $out/tests $out/assets";

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
}
