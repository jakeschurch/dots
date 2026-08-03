{
  vimUtils,
  fetchFromGitHub,
  nix-update-script,
}:

vimUtils.buildVimPlugin {
  pname = "none-ls-nvim-patched";
  version = "0-unstable-2026-01-15";

  src = fetchFromGitHub {
    owner = "ulisses-cruz";
    repo = "none-ls.nvim";
    rev = "main";
    hash = "sha256-nZvUWJpd/uTOwMQpy2ZGMHZ32z9M+IVB1ME4dvDFz8g=";
  };

  doCheck = false;

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
}
