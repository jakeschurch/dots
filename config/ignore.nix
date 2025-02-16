{lib}: let
  addDirEntries = x: [
    x
    "${x}/"
    "${x}/*"
  ];

  dirEntries =
    (map addDirEntries [
      "venv"
      "\.direnv"
      "\.git"
      "\.mypy_cache"
      "\.pytest_cache"
      "\.terraform"
      "\.terragrunt-cache"
      "\.venv"
      "build"
      "dist"
      "node_modules"
      "result"
      "\.venv"
    ])
    ++ [
      "*.pyc"
      "*.pyo"
      "tags"
      "~*"
      ".DS_Store"
    ];
in
  lib.strings.concatLines (lib.flatten dirEntries)
