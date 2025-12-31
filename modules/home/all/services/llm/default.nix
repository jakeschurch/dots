{ pkgs, ... }:
let
  models = import ./models.nix { };
  mcpServers = import ./mcp-servers.nix { inherit pkgs; };
in
{

  imports = [
    (pkgs.callPackage ./opencode.nix { inherit models mcpServers; })
    (pkgs.callPackage ./ollama { inherit models; })
  ];
}
