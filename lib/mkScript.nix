{
  lib,
  makeWrapper,
  pkgs,
  ...
}:
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
  inherit (pkgs) stdenv python3;

  scriptType =
    let
      srcString = builtins.toString src;
      fileContents = builtins.readFile src;
      firstLine = builtins.head (builtins.split "\n" fileContents);
    in
    {
      python = builtins.match srcString ".*\\.py$" != null || firstLine == "#!/usr/bin/env python3";
      shell = builtins.match srcString ".*\\.sh$" != null || firstLine == "#!/bin/bash";
    };

  isPythonScript = scriptType.python;

  propagatedBuildInputsPaths = lib.concatStringsSep ":" (map lib.getBin propagatedBuildInputs);
in
stdenv.mkDerivation {
  inherit
    pname
    version
    src
    nativeBuildInputs
    propagatedBuildInputs
    ;

  buildInputs = buildInputs ++ [ makeWrapper ] ++ (if isPythonScript then [ python3 ] else [ ]);

  installPhase = ''
      mkdir -p $out/bin
      cp ${src} $out/bin/${pname}
      chmod +x $out/bin/${pname}

    wrapProgram $out/bin/${pname} \
      --prefix PATH : "$PATH:${propagatedBuildInputsPaths}" \
      ${
        if isPythonScript then "--set PYTHONPATH $out/lib/python${python3.version}/site-packages" else ""
      }
  '';

  unpackPhase = "true";
  meta = {
    inherit description;
    mainProgram = pname;
  };
}
