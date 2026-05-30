{ inputs, ... }:
let
  inherit (inputs) self deploy-rs;
  activateNixos = host: deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.${host};
in
{
  flake.deploy.nodes = {
    apollo = {
      hostname = "10.10.10.7";
      profiles.system = {
        user = "root";
        path = activateNixos "apollo";
      };
    };

    # artemis = {
    #   hostname = "TODO_ARTEMIS_LAN_IP";
    #   profiles.system = {
    #     user = "root";
    #     path = activateNixos "artemis";
    #   };
    # };
  };

  # Catch deploy-rs schema errors at `nix flake check`
  flake.checks.x86_64-linux = deploy-rs.lib.x86_64-linux.deployChecks inputs.self.deploy;
}
