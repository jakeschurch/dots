{
  pkgs,
  lib,
  models,
  ...
}:
with lib;
let
  # Get model names for Ollama format
  ollamaModels = map (m: m.id) models;

  # Script to pull models on both instances
  ollama-sync-models = pkgs.writeShellApplication {
    name = "ollama-sync-models";
    runtimeInputs = with pkgs; [
      ollama-cuda
      curl
      jq
      coreutils
    ];
    text = ''
      set -euo pipefail

      DESIRED_MODELS="${concatStringsSep " " ollamaModels}"

      sync_instance() {
        NAME="$1"
        HOST="$2"

        echo "=== Syncing $NAME ($HOST) ==="

        # Pull desired models
        for model in $DESIRED_MODELS; do
          echo "Pulling $model..."
          OLLAMA_HOST="$HOST" ollama pull "$model" || true
        done

        echo "Checking for undeclared models..."

        INSTALLED_MODELS=$(curl -s "$HOST/api/tags" \
          | jq -r '.models[].name')

        for installed in $INSTALLED_MODELS; do
          if ! echo "$DESIRED_MODELS" | grep -qx "$installed"; then
            echo "Removing undeclared model: $installed"
            OLLAMA_HOST="$HOST" ollama rm "$installed"
          fi
        done

        echo ""
      }

      sync_instance "NVIDIA" "http://127.0.0.1:11434"

      echo "Model sync complete."
    '';
  };

  # Script to check status of both instances
  ollama-status = pkgs.writeShellApplication {
    name = "ollama-status";
    runtimeInputs = with pkgs; [
      curl
      jq
    ];
    text = ''
      echo "=== NVIDIA 4080 Super (Port 11434) ==="
      if curl -s http://127.0.0.1:11434/api/tags > /dev/null 2>&1; then
        echo "Status: Running"
        echo "Models:"
        curl -s http://127.0.0.1:11434/api/tags | jq -r '.models[].name' | sed 's/^/  /'
      else
        echo "Status: Not responding"
      fi

      echo ""
      echo "=== Intel Arc B60 Pro (Port 11435) ==="
      if curl -s http://127.0.0.1:11435/api/tags > /dev/null 2>&1; then
        echo "Status: Running"
        echo "Models:"
        curl -s http://127.0.0.1:11435/api/tags | jq -r '.models[].name' | sed 's/^/  /'
      else
        echo "Status: Not responding"
      fi
    '';
  };

in
{
  # === NVIDIA 4080 Super - Ollama with CUDA ===
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;
    port = 11434;
    host = "0.0.0.0";
    acceleration = "cuda";

    environmentVariables = {
      CUDA_VISIBLE_DEVICES = "0";
      OLLAMA_NUM_GPU = "999";
      OLLAMA_FLASH_ATTENTION = "1";
      OLLAMA_NUM_PARALLEL = "1";
      OLLAMA_NUM_CTX = "100000";
    };
  };

  # Intel Arc B60 Pro - Ollama via IPEX-LLM

  home.packages = [
    ollama-sync-models
    ollama-status
    pkgs.ollama-cuda
  ];
}
