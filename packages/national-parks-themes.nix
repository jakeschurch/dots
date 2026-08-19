{
  vimUtils,
  fetchFromGitHub,
  nix-update-script,
}:

vimUtils.buildVimPlugin {
  pname = "national-parks-themes";
  version = "0-unstable-2026-08-12";

  src = fetchFromGitHub {
    owner = "pjhamera";
    repo = "national-parks-themes";
    rev = "b1c86cb3697dab9c51fd6931569654bb7bf24769";
    sha256 = "03k2qd83sc8xi71pl9l33q1dz88lwlpr7c0jaqwc5658nmfw7xxy";
  };

  doCheck = false;
  # Terminal emulator palettes and preview art; only colors/ and lua/ matter here.
  postInstall = "rm -rf $out/terminal $out/assets $out/scripts $out/docs";

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
}
