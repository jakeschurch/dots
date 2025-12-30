#!/bin/bash

OLLAMA_MODELS=()
IFS=', ' read -r -a OLLAMA_MODELS <<<"$OLLAMA_MODELS_STRINGIFIED"

check_vars_set() {
  if [ "$OLLAMA_PORT" = "" ]; then
    echo "Error: OLLAMA_PORT is not set" >&2
    exit 1
  fi

  if [ "$OLLAMA_MODELS_STRINGIFIED" = "" ]; then
    echo "Error: no ollama models were not set" >&2
    exit 1
  fi

  if ! command -v ollama &>/dev/null; then
    echo "Error: ollama command not found" >/tmp/ollama-loader-path.txt
    echo "Error: ollama command not found" >&2
    exit 1
  else
    # Debugging: Log the path to ollama
    which ollama >/tmp/ollama-loader-path.txt
  fi
}

wait_ollama_ready() {
  while ! nc -z localhost "$OLLAMA_PORT"; do
    echo "Waiting for Ollama to start..."
    sleep 1
  done
}

remove_unlisted_models() {
  echo "Checking for unlisted models to remove..." >>/tmp/ollama-loader.log

  installed_models=$(ollama list | tail -n +2 | awk '{print $1}')

  # Track removal count
  removed=0

  for installed_model in "${installed_models[@]}"; do
    if ! grep -q "$installed_model" <<<"${OLLAMA_MODELS[*]}"; then
      echo "Removing unlisted model: $installed_model" >>/tmp/ollama-loader.log
      ollama rm "$installed_model"
      removed=$((removed + 1))
    fi
  done

  echo "Removed $removed unlisted models" >>/tmp/ollama-loader.log
}

download_models() {
  total=${#OLLAMA_MODELS[@]}
  failed=0

  echo "total models to download: $total" >>/tmp/ollama-loader.log

  for model in "${OLLAMA_MODELS[@]}"; do
    echo "downloading model: $model" >>/tmp/ollama-loader.log
    if ! ollama pull "$model"; then
      failed=$((failed + 1))
      echo "failed to download model: $model" >>/tmp/ollama-loader.log
    fi
  done

  if [ "$failed" != 0 ]; then
    echo "error: $failed out of $total attempted model downloads failed" >&2
    exit 1
  fi

  echo "all models downloaded successfully" >>/tmp/ollama-loader.log
}

echo "Script started at $(date)" >/tmp/ollama-loader.log

check_vars_set
wait_ollama_ready
remove_unlisted_models
download_models

echo "Script finished at $(date)" >>/tmp/ollama-loader.log
