{
  pkgs,
  lib,
  config,
  models,
  ...
}:
with lib;
let

  ollamaModelNames = map (model: model.id) models;
  ollamaModelNamesStringified = concatStringsSep "," ollamaModelNames;

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
    enable = pkgs.stdenv.isLinux;
    package = pkgs.ollama-cuda;
    port = 11434;
    acceleration = "cuda";
    host = "0.0.0.0";

    environmentVariables = {
      CUDA_VISIBLE_DEVICES = "0";
      OLLAMA_FLASH_ATTENTION = "1";
      OLLAMA_NUM_GPU = "999";

      # Start conservative, tune per agent
      OLLAMA_CONTEXT_LENGTH = "20000";

      OLLAMA_NUM_PARALLEL = "1";
      OLLAMA_MAX_LOADED_MODELS = "2"; # Keep 7B + 14B loaded
    };

  };

  home.packages = mkIf pkgs.stdenv.isLinux [
    ollama-model-loader
  ];

  launchd.agents.ollama-model-loader = mkIf (models != [ ] && pkgs.stdenv.isDarwin) {
    enable = false;
    config = {
      Program = getExe ollama-model-loader;
      EnvironmentVariables = {
        OLLAMA_MODELS_STRINGIFIED = ollamaModelNamesStringified;
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

  systemd.user.services.ollama-model-loader = mkIf (models != [ ] && pkgs.stdenv.isLinux) {
    Unit = {
      Description = "Ollama Model Loader";
      After = [ "network.target" ];
    };
    Service = {
      ExecStart = "${getExe ollama-model-loader}";
      Environment = [
        "OLLAMA_MODELS_STRINGIFIED=${ollamaModelNamesStringified}"
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
