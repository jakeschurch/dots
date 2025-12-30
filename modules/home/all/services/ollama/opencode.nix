{
  pkgs,
  models,
  lib,
  ...
}:
let
  cfg = {
    schema = "https://opencode.ai/config.json";
    theme = "gruvbox";

    model = "ollama/${lib.findFirst (m: m.primary) models.name}";

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
            "${model.name}" = {
              name = model.description;
            };
          }
        ) { } models;
      };
    };
  };
in
{
  home.file.".config/opencode/opencode.json".text = builtins.toJSON cfg;
  home.packages = with pkgs; [ opencode ];
}
