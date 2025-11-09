_: {
  xdg.configFile."hyprpanel/config.json".text = builtins.toJSON (
    let
      config = import ./config.nix;
      theme = import ./theme.nix;
    in
    theme // config
  );
}
