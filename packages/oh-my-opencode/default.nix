{
  pkgs,
  bun2nix ? pkgs.bun2nix,
}:
let
  inherit (bun2nix.passthru) fetchBunDeps writeBunApplication;

  pname = "oh-my-opencode";
  version = "2.12.4";

  src = pkgs.fetchFromGitHub {
    owner = "code-yeongyu";
    repo = "oh-my-opencode";
    rev = "b8b8d14b1ce836ad4b9b6217e713f4efd4bd5df2";
    hash = "sha256-VK1UXFcKHPTMoKPAXSCeo+EJ5xH600xo7NRJiI+Uuo0=";
  };

  bunDeps = fetchBunDeps {
    inherit pname version;
    bunNix = ./bun.nix;
  };
in
writeBunApplication {
  inherit pname version;
  inherit bunDeps src;

  buildPhase = ''
    runHook preBuild
    bun build src/cli/index.ts --outdir dist/cli --target bun --format esm --external @ast-grep/napi
    bun build src/index.ts src/google-auth.ts --outdir dist --target bun --format esm --external @ast-grep/napi
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/lib/oh-my-opencode
    cp -r dist/* $out/lib/oh-my-opencode/

    # Create wrapper script
    cat > $out/bin/oh-my-opencode <<EOF
      #!${pkgs.bash}/bin/bash
      exec ${pkgs.bun}/bin/bun $out/lib/oh-my-opencode/cli/index.js "\$@"
    EOF
    chmod +x $out/bin/oh-my-opencode
    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "OpenCode plugin - custom agents (oracle, librarian) and enhanced features";
    homepage = "https://github.com/code-yeongyu/oh-my-opencode";
    license = licenses.unfree; # SUL-1.0
    maintainers = [ ];
    platforms = platforms.unix;
  };
}
