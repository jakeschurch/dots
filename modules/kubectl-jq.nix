{
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "kubectl-jq";
  version = "0.0.2";

  src = fetchFromGitHub {
    owner = "jrockway";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-tEpp6+KRA0GMgnlLkGbQCT7lP/ta6dpdMbNpbcoDZII=";
  };

  vendorHash = "sha256-iFWr/ZfmcgmxQJfoOC9jyfZFLErsoI3xi38QHERJ7VY=";
}
