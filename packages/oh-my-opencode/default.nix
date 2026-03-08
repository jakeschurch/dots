{
  pkgs,
  bun2nix ? pkgs.bun2nix,
}:
bun2nix.mkDerivation {
  pname = "oh-my-opencode";
  version = "3.1.1";

  src = pkgs.fetchFromGitHub {
    owner = "code-yeongyu";
    repo = "oh-my-opencode";
    rev = "cd23f7ab7d3a245c48990166d676b981de7f1e2a";
    hash = "sha256-kKDmaNcA+7nMt/m1S3oQwQDSx5n97nCPj3mx/KsnnQc=";
  };

  bunDeps = bun2nix.fetchBunDeps {
    bunNix = ./bun.nix;
  };

  # Skip default bun build phase - we need custom build commands
  dontUseBunBuild = true;

  buildPhase = ''
    runHook preBuild
    bun build src/cli/index.ts --outdir dist/cli --target bun --format esm --external @ast-grep/napi
    bun build src/index.ts --outdir dist --target bun --format esm --external @ast-grep/napi
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
