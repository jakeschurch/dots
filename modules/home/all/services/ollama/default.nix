{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  ollamaModels = [
    {
      id = "qwen3:4b-instruct";
      name = "Qwen 3 4B Instruct";
      primary = true;
      num_ctx = 8192; # Default context for fast agents
    }

    {
      id = "qwen3:8b";
      name = "Qwen 3 8B";
      num_ctx = 8192; # Default context for fast agents
    }

    {
      id = "dolphin3:8b";
      name = "Dolphin 3 8B";
      num_ctx = 8192;
    }

    {
      id = "qwen2.5:14b-instruct-q5_K_M";
      name = "Qwen 2.5 14B (Fast)";
      num_ctx = 8192;
    }

    {
      id = "qwen2.5:7b-instruct";
      name = "Qwen 2.5 7B (Fast)";
      num_ctx = 8192;
    }
    {
      id = "llama3.1:8b";
      name = "Llama 3.1 8B";
      num_ctx = 8192;
    }

    {
      id = "deepseek-coder:6.7b-instruct";
      name = "DeepSeek Coder 6.7B";
      num_ctx = 8192;
    }
  ];

  ollamaModelNames = map (model: model.id) ollamaModels;
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
