pkgs: {
  pname,
  src,
  version ? "0.0.0",
  buildInputs ? [],
  nativeBuildInputs ? [],
  propagatedBuildInputs ? [],
  description ? null,
}:
pkgs.stdenv.mkDerivation rec {
  inherit pname version src nativeBuildInputs buildInputs propagatedBuildInputs;

  installPhase = ''
    mkdir -p $out/bin
    cp ${src} $out/bin/${pname}
    chmod +x $out/bin/${pname}
  '';

  unpackPhase = "true";
  meta = {
    inherit description;
    mainProgram = pname;
  };
}
