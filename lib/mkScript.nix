pkgs:
{
  pname,
  src,
  version ? "0.0.0",
  buildInputs ? [ ],
  nativeBuildInputs ? [ ],
  propagatedBuildInputs ? [ ],
  description ? null,
}:
let
  propagatedBuildInputsPaths = pkgs.lib.concatStringsSep ":" (
    map pkgs.lib.getBin propagatedBuildInputs
  );
in
pkgs.stdenv.mkDerivation {
  inherit
    pname
    version
    src
    nativeBuildInputs
    propagatedBuildInputs
    ;

  buildInputs = buildInputs ++ [ pkgs.makeWrapper ];

  installPhase = ''
      mkdir -p $out/bin
      cp ${src} $out/bin/${pname}
      chmod +x $out/bin/${pname}

    wrapProgram $out/bin/${pname} \
      --prefix PATH : "$PATH:${propagatedBuildInputsPaths}"
  '';

  unpackPhase = "true";
  meta = {
    inherit description;
    mainProgram = pname;
  };
}
