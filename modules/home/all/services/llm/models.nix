_: [
  # ===== PRIMARY MODEL =====
  # Qwen 2.5 14B - best balance of quality and speed for dual GPU
  {
    id = "qwen2.5-coder-14b";
    name = "Qwen 2.5 Coder 14B";
    repo = "Qwen/Qwen2.5-Coder-14B-Instruct-GGUF";
    filename = "qwen2.5-coder-14b-instruct-q4_k_m.gguf";
    primary = true;
  }

  # ===== HEAVY TIER (14B+) - Complex Tasks =====
  {
    id = "qwen2.5-14b";
    name = "Qwen 2.5 14B Instruct";
    repo = "Qwen/Qwen2.5-14B-Instruct-GGUF";
    filename = "qwen2.5-14b-instruct-q4_k_m.gguf";
    primary = false;
  }

  {
    id = "deepseek-coder-v2-16b";
    name = "DeepSeek Coder V2 16B";
    repo = "TheBloke/deepseek-coder-16b-instruct-v1.5-GGUF";
    filename = "deepseek-coder-16b-instruct-v1.5.Q4_K_M.gguf";
    primary = false;
  }

  # ===== MEDIUM TIER (7B) - Standard Tasks =====
  {
    id = "glm-4-9b";
    name = "GLM-4 9B";
    repo = "THUDM/glm-4-9b-chat-GGUF";
    filename = "glm-4-9b-chat-Q4_K_M.gguf";
    primary = false;
  }

  {
    id = "qwen2.5-coder-7b";
    name = "Qwen 2.5 Coder 7B";
    repo = "Qwen/Qwen2.5-Coder-7B-Instruct-GGUF";
    filename = "qwen2.5-coder-7b-instruct-q4_k_m.gguf";
    primary = false;
  }

  {
    id = "llama3.1-8b";
    name = "Llama 3.1 8B";
    repo = "bartowski/Meta-Llama-3.1-8B-Instruct-GGUF";
    filename = "Meta-Llama-3.1-8B-Instruct-Q4_K_M.gguf";
    primary = false;
  }

  # ===== LIGHT TIER (3B) - Fast Tasks =====
  {
    id = "qwen2.5-coder-3b";
    name = "Qwen 2.5 Coder 3B";
    repo = "Qwen/Qwen2.5-Coder-3B-Instruct-GGUF";
    filename = "qwen2.5-coder-3b-instruct-q4_k_m.gguf";
    primary = false;
  }

  {
    id = "phi3-mini";
    name = "Phi-3 Mini 3.8B";
    repo = "microsoft/Phi-3-mini-4k-instruct-gguf";
    filename = "Phi-3-mini-4k-instruct-q4.gguf";
    primary = false;
  }
]
