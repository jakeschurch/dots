pkgs:
{
  pname,
  version ? "0.0.0",
  description ? "",
  src,
  pythonPackages ? [ ],
  ...
}:
let
  pythonEnv = pkgs.python312.withPackages (_: pythonPackages);
in
pkgs.stdenv.mkDerivation {
  inherit pname version src;

  buildInputs = [ pkgs.makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    cp ${src} $out/bin/${pname}
    chmod +x $out/bin/${pname}

    wrapProgram $out/bin/${pname} \
      --prefix PYTHONPATH : "${pythonEnv}/${pythonEnv.sitePackages}"
  '';

  unpackPhase = "true";
  meta = {
    inherit description;
  };
}
