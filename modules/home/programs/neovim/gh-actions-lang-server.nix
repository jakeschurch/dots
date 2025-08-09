{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  bun,
  nodejs,
  makeBinaryWrapper,
}:

stdenvNoCC.mkDerivation (_finalAttrs: {
  pname = "gh-actions-language-server";
  version = "0.0.3";

  src = fetchFromGitHub {
    owner = "lttb";
    repo = "gh-actions-language-server";
    rev = "0287d3081d7b74fef88824ca3bd6e9a44323a54d";
    hash = "sha256-ZWO5G33FXGO57Zca5B5i8zaE8eFbBCrEtmwwR3m1Px4=";
  };

  nativeBuildInputs = [
    nodejs
    bun
    makeBinaryWrapper
  ];

  buildPhase = ''
    runHook preBuild
    bun install --no-save
    bun run build:node
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall


    mkdir -p $out/{bin,lib/gh-actions-language-server/bin}
    cp -r node_modules package.json index.js $out/lib/gh-actions-language-server/
    cp -r bin/gh-actions-language-server $out/lib/gh-actions-language-server/bin/

    makeWrapper ${lib.getExe nodejs} $out/bin/gh-actions-language-server \
      --inherit-argv0 \
      --add-flags "$out/lib/gh-actions-language-server/bin/gh-actions-language-server --stdio"

    runHook postInstall
  '';

  doInstallCheck = true;

  meta = {
    description = "Language server for GitHub Actions";
    homepage = "https://github.com/lttb/gh-actions-language-server";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "gh-actions-language-server";
    platforms = lib.platforms.all;
  };
})
