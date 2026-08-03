{
  vimUtils,
  fetchFromGitHub,
  nix-update-script,
}:

vimUtils.buildVimPlugin {
  pname = "ghlite-nvim";
  version = "0-unstable-2026-07-02";

  src = fetchFromGitHub {
    owner = "daliusd";
    repo = "ghlite.nvim";
    rev = "dc3af8cb7304dfe6959ede75a0bfc63a52cf704f";
    sha256 = "sha256-SItDmKnUwwpoyx79yBtWXMFFhYTwoXIndGXJLhAtu6M=";
  };

  doCheck = false;
  postInstall = "rm -rf $out/test $out/tests $out/spec";

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
}
