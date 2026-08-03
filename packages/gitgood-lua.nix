{
  vimUtils,
  fetchFromGitHub,
  gh,
  lib,
  nix-update-script,
}:

# PR review, fugitive-style. gh's store path is baked into gh_cmd so the plugin
# carries its own gh (gh auth still comes from the user env).
vimUtils.buildVimPlugin {
  pname = "gitgood-lua";
  version = "0-unstable-2026-01-15";

  src = fetchFromGitHub {
    owner = "jakeschurch";
    repo = "gitgood.lua";
    rev = "49922bc30d6f9bd3da74b99800f60c85dc5504cc";
    hash = "sha256-MLTsbf1laBgY9KgC27wgk0Dogr+CsS8MMWzHQy9iqdI=";
  };

  postPatch = ''
    substituteInPlace lua/gitgood/config.lua \
      --replace-fail 'gh_cmd = "gh"' 'gh_cmd = "${lib.getExe gh}"'
  '';

  doCheck = false;

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
}
