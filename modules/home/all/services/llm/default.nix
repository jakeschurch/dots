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
    llama-cpp
    (import ./agents {
      inherit
        lib
        tools
        models
        mcpServers
        ;
    })
  ];

  home.packages = with pkgs; [
    claude-code
    claude-code-acp
  ];
}
