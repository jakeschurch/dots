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
  isShellScript = scriptType.shell;

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

  buildInputs =
    buildInputs ++ [ pkgs.makeWrapper ] ++ (if isPythonScript then with pkgs; [ python3 ] else [ ]);

  installPhase = ''
      mkdir -p $out/bin
      cp ${src} $out/bin/${pname}
      chmod +x $out/bin/${pname}

    wrapProgram $out/bin/${pname} \
      --prefix PATH : "$PATH:${propagatedBuildInputsPaths}" \
      ${
        if isPythonScript then
          "--set PYTHONPATH $out/lib/python${pkgs.python3.version}/site-packages"
        else
          ""
      }
  '';

  unpackPhase = "true";
  meta = {
    inherit description;
    mainProgram = pname;
  };
}
