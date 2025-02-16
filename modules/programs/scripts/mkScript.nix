stdenv: {
  pname,
  src,
  version ? "0.0",
  nativeBuildInputs ? [],
  description ? null,
}:
stdenv.mkDerivation rec {
  inherit pname version src nativeBuildInputs;

  installPhase = ''
    mkdir -p $out/bin
    cp ${src} $out/bin/${pname}
    chmod +x $out/bin/${pname}
  '';

  unpackPhase = "true";
  meta = {
    inherit description;
  };
}
