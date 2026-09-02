{
  pkgs,
  ...
}:
{
  home.packages = [
    pkgs.datadog-ci
  ];
}
