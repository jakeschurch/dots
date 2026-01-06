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

  ollama = import ./ollama {
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
    ollama
    (import ./agents { inherit lib tools mcpServers; })
  ];

  home.packages = with pkgs; [
    claude-code
    claude-code-acp
  ];
}
