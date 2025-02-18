{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  ollamaModels = [
    "codellama:13b-instruct"
    "hf.co/Kortix/FastApply-7B-v1.0_GGUF:Q4_K_M"
  ];

  ollama-model-loader = pkgs.lib.mkScript {
    pname = "ollama-model-loader";
    src = ./ollama-model-loader.sh;
    propagatedBuildInputs = [
      config.services.ollama.package
    ];
  };
in {
  services.ollama = {
    enable = true;
    port = 11434;
    acceleration = null;
  };

  home.packages = [
    ollama-model-loader
  ];

  launchd.agents.ollama-model-loader = mkIf (ollamaModels != [] && pkgs.stdenv.isDarwin) {
    enable = true;
    config = {
      Program = getExe ollama-model-loader;
      EnvironmentVariables = {
        OLLAMA_MODELS_STRINGIFIED = concatStringsSep "," ollamaModels;
        OLLAMA_PORT =
          toString config.services.ollama.port;
        OLLAMA_HOST = "localhost:${toString config.services.ollama.port}";
      };
      KeepAlive = {
        Crashed = true;
        SuccessfulExit = false;
      };
      ProcessType = "Background";
      StartInterval = 10;
    };
  };
}
