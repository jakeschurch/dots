{
  flake,
  pkgs,
  ...
}:
{
  virtualisation.docker = {
    enable = true;

    # Reclaim disk space from stopped containers / dangling images weekly.
    autoPrune = {
      enable = true;
      dates = "weekly";
      flags = [ "--all" ];
    };

    daemon.settings = {
      # Higher NOFILE helps builds that open many layer files concurrently.
      default-ulimits = {
        nofile = {
          Hard = 64000;
          Name = "nofile";
          Soft = 64000;
        };
      };
      # Use json-file logging with a size cap so containers can't fill /var.
      log-driver = "json-file";
      log-opts = {
        max-size = "100m";
        max-file = "3";
      };
    };
  };

  # docker-compose v2 ships as a CLI plugin with the daemon; installing it
  # systemwide gives `docker compose ...` without a home-manager dep.
  environment.systemPackages = with pkgs; [
    docker-compose
  ];

  # Access the socket without sudo. config.me.username is the flake-wide
  # identity helper used elsewhere in this repo.
  users.users.${flake.config.me.username}.extraGroups = [ "docker" ];
}
