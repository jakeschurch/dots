{
  pkgs,
  models,
  mcpServers,
  tools,
  lib,
}:
let
  # llama.cpp serves on port 11434 with OpenAI-compatible API
  llamaCppPort = 11434;
  llamaCppHost = "127.0.0.1";

  cfg = {
    "$schema" = "https://opencode.ai/config.json";
    theme = "gruvbox";
    plugin = [ "oh-my-opencode" ];

    model =
      let
        primaryModel = lib.findFirst (m: m ? primary && m.primary) null models;
        primaryModelName =
          if primaryModel != null then
            primaryModel.id
          else
            assert false;
            "Primary model not found";
      in
      "llama-cpp/${primaryModelName}";

    provider = {
      llama-cpp = {
        npm = "@ai-sdk/openai-compatible";
        name = "llama.cpp";
        options = {
          baseURL = "http://${llamaCppHost}:${toString llamaCppPort}/v1";
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
            // lib.foldl' (acc: key: acc // lib.nameValuePair key "{env:${key}}") { } (server.env_keys or [ ]);
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
      lib.mapAttrs (_name: _tool: true) tools // lib.mapAttrs (_name: _tool: true) mcpServers;

    permission = tools // lib.mapAttrs (_name: tool: tool.permission) mcpServers;
  };
in
{
  home.file.".config/opencode/opencode.json".text = builtins.toJSON cfg;
  home.packages = with pkgs; [
    opencode
    oh-my-opencode
  ];
}
