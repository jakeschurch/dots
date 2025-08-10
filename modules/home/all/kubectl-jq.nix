{
  pkgs,
  ...
}:
let
  kubectl-jq = pkgs.buildGoModule rec {
    pname = "kubectl-jq";
    version = "0.0.2";

    src = pkgs.fetchFromGitHub {
      owner = "jrockway";
      repo = pname;
      rev = "v${version}";
      sha256 = "sha256-tEpp6+KRA0GMgnlLkGbQCT7lP/ta6dpdMbNpbcoDZII=";
    };

    vendorHash = "sha256-iFWr/ZfmcgmxQJfoOC9jyfZFLErsoI3xi38QHERJ7VY=";
  };
in
{
  home.packages = [
    kubectl-jq
  ];
}
