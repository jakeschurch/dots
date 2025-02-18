{
  pkgs,
  inputs,
  ...
}: {
  mkScript = import ./mkScript.nix pkgs;
  mkPythonApp = import ./mkPython.nix pkgs;
  mkHome = import ./mkHome.nix {inherit pkgs inputs;};
}
