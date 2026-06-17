{
  pkgs ? import <nixpkgs> { },
}:

pkgs.buildGoModule rec {
  pname = "terragrunt-ls";
  version = "0.0.5-unstable-2026-06-03";

  src = pkgs.fetchFromGitHub {
    owner = "gruntwork-io";
    repo = "terragrunt-ls";
    rev = "a4433593928116d6a743c72c0dfe2dd8a0870184";
    sha256 = "sha256-G40XYqgDF6XP1S5rRejuFtyXMr5mxLQjJ5eItQcjrGA=";
  };

  vendorHash = "sha256-wqQPMVP2822N55m5A0/EiCzgVPITJkfrKlHwQWvSte0=";

  subPackages = [ "." ];

  ldflags = [
    "-s"
    "-w"
  ];

  # Optional: add a check phase later once tests exist
  doCheck = false;

  passthru.updateScript = pkgs.nix-update-script {
    # No upstream releases yet; track default-branch commits.
    extraArgs = [ "--version=branch" ];
  };

  meta = with pkgs.lib; {
    description = "A language server for Terragrunt configuration files";
    homepage = "https://github.com/gruntwork-io/terragrunt-ls";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.unix;
  };
}
