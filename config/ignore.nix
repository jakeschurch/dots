{lib}: let
  addDirEntries = x: [
      x
      "${x}/"
      "${x}/*"
    ];
  dirEntries = (map addDirEntries [
    "node_modules"
    "result"
    "\.direnv"
    "\.git"
    "\.terragrunt-cache"
    "\.terraform"
    "\.venv"
    "\.mypy_cache"
  ]) |> lib.flatten |> lib.strings.concatLines;
in
  dirEntries
