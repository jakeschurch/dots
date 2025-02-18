#!/bin/bash

# Debugging: Print the script's start time
echo "Script started at $(date)" >/tmp/ollama-loader.log

# Check if OLLAMA_PORT is set
if [ -z "$OLLAMA_PORT" ]; then
  echo "Error: OLLAMA_PORT is not set" >&2
  exit 1
fi

# Check if OLLAMA_MODELS is set
if [ -z "$OLLAMA_MODELS_STRINGIFIED" ]; then
  echo "Error: no ollama models were not set" >&2
  exit 1
fi

# Wait for Ollama to be ready
while ! nc -z localhost "$OLLAMA_PORT"; do
  echo "Waiting for Ollama to start..."
  sleep 1
done

# Debugging: Log environment variables
env >/tmp/ollama-loader-env.txt

# Check if ollama is installed
if ! command -v ollama &>/dev/null; then
  echo "Error: ollama command not found" >/tmp/ollama-loader-path.txt
  echo "Error: ollama command not found" >&2
  exit 1
else
  # Debugging: Log the path to ollama
  which ollama >/tmp/ollama-loader-path.txt
fi

# Define the models to download
OLLAMA_MODELS=("$")
IFS=', ' read -r -a OLLAMA_MODELS <<<"$OLLAMA_MODELS_STRINGIFIED"
total=${#OLLAMA_MODELS[@]}
failed=0

echo "Total models to download: $total" >>/tmp/ollama-loader.log

# Download each model in parallel
for model in "${OLLAMA_MODELS[@]}"; do
  echo "Downloading model: $model" >>/tmp/ollama-loader.log
  ollama pull "$model" &
done

# Wait for all jobs to finish
for job in $(jobs -p); do
  set +e
  wait "$job"
  exit_code=$?
  set -e

  if [ "$exit_code" != 0 ]; then
    failed=$((failed + 1))
    echo "Failed to download model: $model (exit code: $exit_code)" >>/tmp/ollama-loader.log
  fi
done

# If any model download fails, exit with error
if [ "$failed" != 0 ]; then
  echo "Error: $failed out of $total attempted model downloads failed" >&2
  exit 1
fi

echo "All models downloaded successfully" >>/tmp/ollama-loader.log
echo "Script finished at $(date)" >>/tmp/ollama-loader.log
