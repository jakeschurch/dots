{
  vimUtils,
  fetchFromGitHub,
  nix-update-script,
}:

vimUtils.buildVimPlugin {
  pname = "none-ls-nvim-patched";
  version = "0-unstable-2025-04-28";

  src = fetchFromGitHub {
    owner = "ulisses-cruz";
    repo = "none-ls.nvim";
    rev = "30aa4964496e82774a443824108042e4db351353";
    hash = "sha256-nZvUWJpd/uTOwMQpy2ZGMHZ32z9M+IVB1ME4dvDFz8g=";
  };

  doCheck = false;

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
}
