{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  ollamaModels = [
    "codellama:7b"
    "qwen2.5-coder:7b"
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
    enable = false;
    port = 11434;
    acceleration = null;
  };

  home.packages = [
    # ollama-model-loader
  ];

  launchd.agents.ollama-model-loader = mkIf (ollamaModels != [] && pkgs.stdenv.isDarwin) {
    enable = false;
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
      RunAtLoad = true;
      StartInterval = 0;
    };
  };
}
