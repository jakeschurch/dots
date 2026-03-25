{
  pkgs,
  lib,
  config,
  ...
}:
let
  models = import ./models.nix { };
  mcpServers = import ./mcp-servers.nix { };
  tools = import ./tools.nix { };

  opencode = import ./opencode.nix {
    inherit
      models
      mcpServers
      tools
      pkgs
      lib
      ;
  };

  oh-my-opencode = import ./oh-my-opencode.nix {
    inherit
      pkgs
      lib
      models
      ;
  };

  llama-cpp = import ./llama-cpp {
    inherit
      pkgs
      models
      lib
      config
      ;
  };
in
{
  imports = [
    opencode
    oh-my-opencode
    (import ./agents {
      inherit
        lib
        tools
        models
        mcpServers
        ;
    })
  ];
}
