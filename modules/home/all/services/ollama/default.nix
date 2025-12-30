{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  ollamaModels = [
    "qwen2.5-coder:14b-instruct-q4_K_M"
    "deepseek-coder:6.7b-instruct"
    "codellama:7b"
    "hf.co/Kortix/FastApply-7B-v1.0_GGUF:Q4_K_M"
  ];

  ollama-model-loader = pkgs.lib.mkScript {
    pname = "ollama-model-loader";
    src = ./ollama-model-loader.sh;
    propagatedBuildInputs = [
      config.services.ollama.package
    ];
  };
in
{
  services.ollama = {
    enable = true;
    port = 11434;
    acceleration = "cuda";
    host = "0.0.0.0";
    environmentVariables = {
      CUDA_VISIBLE_DEVICES = "0";
      OLLAMA_FLASH_ATTENTION = "1";
      OLLAMA_CONTEXT_LENGTH = "131072";

      # Let it use system RAM for context overflow
      OLLAMA_NUM_GPU = "999"; # Put as much as possible on GPU
    };
  };

  home.packages = [
    ollama-model-loader
  ];

  launchd.agents.ollama-model-loader = mkIf (ollamaModels != [ ] && pkgs.stdenv.isDarwin) {
    enable = false;
    config = {
      Program = getExe ollama-model-loader;
      EnvironmentVariables = {
        OLLAMA_MODELS_STRINGIFIED = concatStringsSep "," ollamaModels;
        OLLAMA_PORT = toString config.services.ollama.port;
        OLLAMA_HOST = "${config.services.ollama.host}:${toString config.services.ollama.port}";
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

  systemd.user.services.ollama-model-loader = mkIf (ollamaModels != [ ] && pkgs.stdenv.isLinux) {
    Unit = {
      Description = "Ollama Model Loader";
      After = [ "network.target" ];
    };
    Service = {
      ExecStart = "${getExe ollama-model-loader}";
      Environment = [
        "OLLAMA_MODELS_STRINGIFIED=${concatStringsSep "," ollamaModels}"
        "OLLAMA_PORT=${toString config.services.ollama.port}"
        "OLLAMA_HOST=${config.services.ollama.host}:${toString config.services.ollama.port}"
      ];
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
