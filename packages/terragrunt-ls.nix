{
  pkgs ? import <nixpkgs> { },
}:

pkgs.buildGoModule rec {
  pname = "terragrunt-ls";
  version = "0.0.6-unstable-2026-07-13";

  src = pkgs.fetchFromGitHub {
    owner = "gruntwork-io";
    repo = "terragrunt-ls";
    rev = "2f11188deb09f526eec989e9e9b390ced9775575";
    sha256 = "sha256-PIIpD6dicVdBcRRIi0x1QkrXsAlOVpV9VmRdlaTONrI=";
  };

  vendorHash = "sha256-e/wkxm6phlbBB3fA4lgdI1hOgjaK6Uq5pB0zrHRgGAM=";

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
