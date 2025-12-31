{
  pkgs,
  models,
  mcpServers,
  tools,
  lib,
}:
let
  cfg = {
    "$schema" = "https://opencode.ai/config.json";
    theme = "gruvbox";

    model =
      let
        primaryModel = lib.findFirst (m: m.primary) null models;
        primaryModelName =
          if primaryModel != null then
            primaryModel.id
          else
            assert false;
            "Primary model not found";
      in
      "ollama/${primaryModelName}";

    provider = {
      ollama = {
        npm = "@ai-sdk/openai-compatible";
        name = "Ollama";
        options = {
          baseURL = "http://10.10.5.52:11434/v1";
        };

        models = builtins.foldl' (
          acc: model:
          acc
          // {
            "${model.id}" = {
              inherit (model) name;
            };
          }
        ) { } models;
      };
    };

    mcp =
      let
        mkLocalDef = server: {
          inherit (server) command;

          type = "local";
          timeout = server.timeout or 60;
          environment =
            server.env or { }
            // lib.foldl' (
              acc: key:
              acc
              // {
                "${key}" = "{env:${key}}";
              }
            ) { } (server.env_keys or [ ]);
        };

        mkRemoteDef = server: {
          inherit (server) url;
          type = "remote";

          timeout = server.timeout or 60;
          headers = server.headers or { };
        };

        toDefinition = server: if server ? url then mkRemoteDef server else mkLocalDef server;

      in
      lib.mapAttrs (_name: toDefinition) mcpServers;

    tools =
      # NOTE: disable mcp tools globally so we can instead set permissions per-agent
      lib.mapAttrs (name: _tool: { "${name}" = false; }) tools
      // lib.mapAttrs (name: _tool: { "${name}" = false; }) mcpServers;

    permission = tools // lib.mapAttrs (name: tool: { "${name}" = tool.permission; }) mcpServers;
  };
in
{
  home.file.".config/opencode/opencode.json".text = builtins.toJSON cfg;
  home.packages = with pkgs; [ opencode ];
}
