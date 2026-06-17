{
  vimUtils,
  fetchFromGitHub,
  nix-update-script,
}:

vimUtils.buildVimPlugin {
  pname = "none-ls-shellcheck-nvim";
  version = "0-unstable-2024-03-19";

  src = fetchFromGitHub {
    owner = "gbprod";
    repo = "none-ls-shellcheck.nvim";
    rev = "0f84461241e76e376a95fb7391deac82dc3efdbf";
    sha256 = "0xjlsq6p4x77g24ixhi1ss8vvq5ydkx8g6d6nl4nl40mpjxqskmp";
  };

  doCheck = false;
  postInstall = "rm -rf $out/test $out/tests $out/spec";

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
}
