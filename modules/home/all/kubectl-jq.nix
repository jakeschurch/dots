{
  pkgs,
  ...
}:
{
  home.packages = [
    pkgs.kubectl-jq
  ];
}
