{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
}:

let
  version = "5.23.0";

  # Hashes come from the release's checksums.txt (hex -> SRI).
  sources = {
    "x86_64-linux" = {
      plat = "linux-x64";
      hash = "sha256-34LLYeadkZ5VRvZydd7DrU6JcoivnpmRsjovTGNDlMQ=";
    };
    "aarch64-linux" = {
      plat = "linux-arm64";
      hash = "sha256-7X/eSgWdllMhFaY4zl+a1XQNkcGlhNAWQpXGCiufsR4=";
    };
    "x86_64-darwin" = {
      plat = "darwin-x64";
      hash = "sha256-26ikzDHIz9/fO7MM7UWvBfAq27+iWOjkiqYs0QKsEi4=";
    };
    "aarch64-darwin" = {
      plat = "darwin-arm64";
      hash = "sha256-D7DtRGrSGlu8bNx7TA/Un2dxo4NYQdXXwak/R0P/EOs=";
    };
  };

  source =
    sources.${stdenv.hostPlatform.system}
      or (throw "datadog-ci: unsupported platform ${stdenv.hostPlatform.system}");
in
# Prebuilt release binary: not in nixpkgs, and the npm package root
# (github:datadog/datadog-ci) is a monorepo with no `bin`.
stdenvNoCC.mkDerivation {
  pname = "datadog-ci";
  inherit version;

  src = fetchurl {
    url = "https://github.com/DataDog/datadog-ci/releases/download/v${version}/datadog-ci_${source.plat}";
    inherit (source) hash;
  };

  # Node single-executable binary: dynamically linked, so the ELF
  # interpreter/rpath need patching on Linux.
  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ stdenv.cc.cc.lib ];

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/datadog-ci
    runHook postInstall
  '';

  meta = {
    description = "Datadog CI/CD integration CLI";
    homepage = "https://github.com/DataDog/datadog-ci";
    license = lib.licenses.asl20;
    mainProgram = "datadog-ci";
    platforms = builtins.attrNames sources;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
