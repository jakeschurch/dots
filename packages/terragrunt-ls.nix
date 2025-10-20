{
  pkgs ? import <nixpkgs> { },
}:

pkgs.buildGoModule {
  pname = "terragrunt-ls";
  name = "terragrunt-ls";

  src = pkgs.fetchFromGitHub {
    owner = "gruntwork-io";
    repo = "terragrunt-ls";
    rev = "a82e24338bae87e5a3d1e8cf81179ce8a848ae3e";
    sha256 = "sha256-Ni9TccTLbixtczJvKDUJqgGwFCj9TRNX0zp6421BaYY=";
  };

  vendorHash = "sha256-U9IEV0RQbqqLIw+DUeCT1pbHubJ0nEC/ySZmFZAHBb0=";

  subPackages = [ "." ];

  ldflags = [
    "-s"
    "-w"
  ];

  # Optional: add a check phase later once tests exist
  doCheck = false;

  meta = with pkgs.lib; {
    description = "A language server for Terragrunt configuration files";
    homepage = "https://github.com/gruntwork-io/terragrunt-ls";
    license = licenses.mit;
    maintainers = [ maintainers.yourname ];
    platforms = platforms.unix;
  };
}
