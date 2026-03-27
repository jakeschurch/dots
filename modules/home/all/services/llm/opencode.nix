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
      "${primaryModelName}";

    provider = {
      # NVIDIA 4080 Super - Ollama with CUDA (Primary)
      nvidia = {
        npm = "@ai-sdk/openai-compatible";
        name = "NVIDIA 4080 Super";
        options = {
          baseURL = "http://127.0.0.1:11434/v1";
        };
        models = builtins.foldl' (
          acc: model: acc // { "${model.id}" = { inherit (model) name; }; }
        ) { } models;
      };

      # Intel Arc B60 Pro - Ollama with IPEX-LLM
      intel = {
        npm = "@ai-sdk/openai-compatible";
        name = "Intel Arc B60 Pro";
        options = {
          baseURL = "http://127.0.0.1:11435/v1";
        };
        models = builtins.foldl' (
          acc: model: acc // { "${model.id}" = { inherit (model) name; }; }
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

    tools = lib.mapAttrs (_name: _tool: true) tools // lib.mapAttrs (_name: _tool: true) mcpServers;

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
