{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  ollamaModels = [
    # Primary models - Fast 7B for quick tasks
    {
      name = "qwen2.5-coder:7b-instruct";
      description = "Qwen 2.5 Coder 7B (Fast)";
      primary = true;
      num_ctx = 8192; # Default context for fast agents
    }

    # Primary models - Powerful 14B for complex work
    {
      name = "qwen2.5-coder:14b-instruct-q4_K_M";
      description = "Qwen 2.5 Coder 14B Q4 (Powerful)";
      num_ctx = 16384; # Higher context for complex tasks
    }

    # Alternative fast model
    {
      name = "deepseek-coder:6.7b-instruct";
      description = "DeepSeek Coder 6.7B";
      num_ctx = 8192;
    }
  ];

  ollamaModelNames = map (model: model.name) ollamaModels;
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
    port = 11434;
    acceleration = "cuda";
    host = "0.0.0.0";

    environmentVariables = {
      CUDA_VISIBLE_DEVICES = "0";
      OLLAMA_FLASH_ATTENTION = "1";

      # Start conservative, tune per agent
      OLLAMA_CONTEXT_LENGTH = "8192";

      OLLAMA_NUM_GPU = "999";
      OLLAMA_NUM_PARALLEL = "1";
      OLLAMA_MAX_LOADED_MODELS = "2"; # Keep 7B + 14B loaded
    };

  };

  imports = [
    (import ./opencode.nix {
      inherit pkgs lib;
      models = ollamaModels;
    })
  ];

  home.packages = mkIf pkgs.stdenv.isLinux [
    ollama-model-loader
  ];

  launchd.agents.ollama-model-loader = mkIf (ollamaModels != [ ] && pkgs.stdenv.isDarwin) {
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

  systemd.user.services.ollama-model-loader = mkIf (ollamaModels != [ ] && pkgs.stdenv.isLinux) {
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
