{pkgs, ...}: {
  home.packages = with pkgs; [
    (ripgrep.override {withPCRE2 = true;})
  ];

  home.file.".rgignore".text = pkgs.callPackage ../../config/ignore.nix {};
}
