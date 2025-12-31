{
  pkgs,
  models,
  mcpServers,
  lib,
  ...
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
            primaryModel.name
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
              inherit (model) description;
            };
          }
        ) { } models;
      };
    };

    mcp =
      let
        mkLocalDef = server: {
          enabled = true;
          type = "local";
          inherit (server) command;
          timeout = server.timeout or 60;
          environment =
            server.env or { }
            // lib.optionalAttrs (server ? env_keys) (
              lib.foldl' (
                acc: key:
                acc
                // {
                  "${key}" = "{env:${key}}";
                }
              ) { } server.env_keys
            );
        };

        mkRemoteDef = server: {
          inherit (server) url;
          type = "remote";

          enabled = server.enabled or true;
          timeout = server.timeout or 60;
          headers = server.headers or { };
        };

        toDefinition = server: if server ? uri then mkRemoteDef server else mkLocalDef server;

      in
      builtins.foldAttrs' (
        acc: name: server:
        acc
        // {
          "${name}" = toDefinition server;
        }
      ) { } mcpServers;

    tools = {
      write = true;
      edit = true;
      read = true;
      grep = true;
      glob = true;
      list = true;
      lsp = true;
      bash = true;
      patch = true;
      skill = true;
      webfetch = true;
      todowrite = true;
      todoread = true;
    };

    permission = {
      edit = "allow";
      bash = "ask";
      read = "allow";
      write = "allow";
      grep = "allow";
      glob = "allow";
      list = "allow";
      lsp = "allow";
      patch = "allow";
      skill = "allow";
      webfetch = "allow";
      todowrite = "allow";
      todoread = "allow";
    };
  };
in
{
  home.file.".config/opencode/opencode.json".text = builtins.toJSON cfg;
  home.packages = with pkgs; [ opencode ];
}
