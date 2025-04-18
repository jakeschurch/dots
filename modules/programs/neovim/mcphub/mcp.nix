{
  pkgs,
}:

let
  python = pkgs.python311;
  pythonPackages = python.pkgs;
in

pythonPackages.buildPythonPackage rec {
  pname = "mcp";
  version = "1.2.0"; # Replace with the actual version

  src = pkgs.fetchFromGitHub {
    owner = "modelcontextprotocol";
    repo = "python-sdk";
    rev = "v${version}";
    sha256 = "sha256-NAsA8qjh/SoCuhPDRGmPNRWNkxD4gP0lN+ZdnCNYZ7s=";
  };

  format = "pyproject";

  nativeBuildInputs = with pythonPackages; [ hatchling ];

  propagatedBuildInputs = with pythonPackages; [
    anyio
    click
    httpx
    httpx-sse
    pydantic
    pydantic-settings
    sse-starlette
    starlette
    uvicorn
  ];

  doCheck = false;
}
