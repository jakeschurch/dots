{
  flake,
  ...
}:
let
  inherit (flake) inputs config;
  inherit (inputs) self;
in
{
  imports = [
    self.nixosModules.common
    inputs.nix-index-database.nixosModules.nix-index
    {
      home-manager = {
        users.${config.me.username} = {
imports = [

		    self.homeModules.default
		    self.homeModules.linux-only
];
};
	sharedModules = [
		    self.homeModules.default
		    self.homeModules.linux-only
	];
        backupFileExtension = "nix-bak";
      };
    }
    ./steam.nix
    ./ssh.nix
  ];

  boot.loader.grub.configurationLimit = 2;
}
