{ ...}: {
  imports = [
    ./programs
    ./services
    ./development.nix
    ./rc.nix
    ./home-environment.nix
    ./work.nix
  ];
}
