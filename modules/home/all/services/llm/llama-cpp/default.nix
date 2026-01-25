{
  pkgs,
  lib,
  config,
  models,
  ...
}:
with lib;
let
  # Configuration
  llamaCppPort = 11434; # Same port as Ollama for compatibility
  modelDir = "${config.home.homeDirectory}/.local/share/llama-cpp/models";

  # Get primary model
  primaryModel = lib.findFirst (m: m ? primary && m.primary) (head models) models;

  # Model downloader script using huggingface-cli
  llama-model-downloader = pkgs.writeShellApplication {
    name = "llama-model-downloader";
    runtimeInputs = with pkgs; [
      python3Packages.huggingface-hub
      coreutils
      jq
    ];
    text = ''
      set -e

      MODEL_DIR="${modelDir}"
      mkdir -p "$MODEL_DIR"

      download_model() {
        local repo="$1"
        local filename="$2"
        local target="$MODEL_DIR/$filename"

        if [ -f "$target" ]; then
          echo "Model already exists: $target"
          return 0
        fi

        echo "Downloading $repo/$filename..."
        huggingface-cli download "$repo" "$filename" --local-dir "$MODEL_DIR" --local-dir-use-symlinks False
        echo "Downloaded: $target"
      }

      # Download configured models
      ${concatMapStringsSep "\n" (m:
        if m ? repo && m ? filename then
          ''download_model "${m.repo}" "${m.filename}"''
        else
          ""
      ) models}

      echo "All models ready in $MODEL_DIR"
    '';
  };

  # llama.cpp server start script with multi-GPU support (Vulkan for Intel+NVIDIA)
  llama-server-start = pkgs.writeShellApplication {
    name = "llama-server-start";
    runtimeInputs = with pkgs; [
      llama-cpp-vulkan-multi
      coreutils
    ];
    text = ''
      set -e

      MODEL_DIR="${modelDir}"
      MODEL_OVERRIDE_FILE="${modelDir}/.current-model"
      DEFAULT_MODEL="${primaryModel.filename or ""}"

      # Check for model override
      if [ -f "$MODEL_OVERRIDE_FILE" ]; then
        SELECTED_MODEL=$(cat "$MODEL_OVERRIDE_FILE")
      else
        SELECTED_MODEL="$DEFAULT_MODEL"
      fi

      MODEL_PATH="$MODEL_DIR/$SELECTED_MODEL"

      if [ ! -f "$MODEL_PATH" ]; then
        echo "Error: Model not found at $MODEL_PATH"
        echo "Run 'llama-model-downloader' first to download models"
        echo "Available models:"
        ls -1 "$MODEL_DIR"/*.gguf 2>/dev/null || echo "  None"
        exit 1
      fi

      echo "Starting llama.cpp server with model: $SELECTED_MODEL"
      echo "Using Vulkan multi-GPU (Intel B60 + NVIDIA 4080 Super)"

      # Vulkan multi-GPU for Intel Arc B60 (12GB) + 4080 Super (16GB)
      # Split ~43% to B60, ~57% to 4080 based on VRAM ratio
      exec llama-server \
        --host 0.0.0.0 \
        --port ${toString llamaCppPort} \
        --model "$MODEL_PATH" \
        --ctx-size 32768 \
        --n-gpu-layers 999 \
        --tensor-split 0.43,0.57 \
        --threads 16 \
        --parallel 1 \
        --cont-batching \
        --mmap
    '';
  };

  # Script to switch models on-the-fly (restarts service)
  llama-switch-model = pkgs.writeShellApplication {
    name = "llama-switch-model";
    runtimeInputs = with pkgs; [ systemd coreutils findutils ];
    text = ''
      MODEL_DIR="${modelDir}"
      MODEL_OVERRIDE_FILE="$MODEL_DIR/.current-model"
      MODEL_NAME="''${1:-}"

      if [ -z "$MODEL_NAME" ]; then
        echo "Usage: llama-switch-model <model-filename>"
        echo ""
        echo "Available models:"
        find "$MODEL_DIR" -maxdepth 1 -name "*.gguf" -printf "%f\n" 2>/dev/null || echo "  No models found"
        echo ""
        if [ -f "$MODEL_OVERRIDE_FILE" ]; then
          echo "Current: $(cat "$MODEL_OVERRIDE_FILE")"
        fi
        exit 0
      fi

      # Validate model exists
      if [ ! -f "$MODEL_DIR/$MODEL_NAME" ]; then
        echo "Error: Model not found: $MODEL_NAME"
        exit 1
      fi

      echo "$MODEL_NAME" > "$MODEL_OVERRIDE_FILE"
      systemctl --user restart llama-server
      echo "Switching to: $MODEL_NAME"
      echo "Server restarting..."
    '';
  };

in
{
  systemd.user.services.llama-server = mkIf pkgs.stdenv.isLinux {
    Unit = {
      Description = "llama.cpp Server (Multi-GPU)";
      After = [ "network.target" ];
    };
    Service = {
      ExecStart = getExe llama-server-start;
      Environment = [
        # Vulkan settings for multi-GPU
        "GGML_VK_VISIBLE_DEVICES=0,1"
        # Use both Intel and NVIDIA Vulkan devices
        "VK_LOADER_DEBUG=error"
      ];
      Restart = "on-failure";
      RestartSec = "5s";
      # Resource limits
      MemoryMax = "48G";
      CPUQuota = "400%";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  # Model downloader service (runs once on activation)
  systemd.user.services.llama-model-downloader = mkIf pkgs.stdenv.isLinux {
    Unit = {
      Description = "llama.cpp Model Downloader";
      Before = [ "llama-server.service" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = getExe llama-model-downloader;
      Environment = [
        "HOME=${config.home.homeDirectory}"
      ];
    };
  };

  home.packages = with pkgs; [
    llama-cpp-vulkan-multi
    llama-model-downloader
    llama-switch-model
    python3Packages.huggingface-hub
  ];

  # Create model directory
  home.file."${modelDir}/.keep".text = "";
}
