_: [
  # ===== PRIMARY / GENERAL PURPOSE =====
  {
    id = "qwen2.5:latest";
    name = "Qwen 2.5 (Latest)";
    primary = true;
  }
  {
    id = "qwen3:14b";
    name = "Qwen 3 14B";
    primary = false;
  }
  {
    id = "llama3.1:8b";
    name = "Llama 3.1 8B";
    primary = false;
  }

  # ===== HEAVY TIER (14B) =====
  {
    id = "qwen2.5:14b";
    name = "Qwen 2.5 14B";
    primary = false;
  }
  {
    id = "phi3:14b";
    name = "Phi 3 14B";
    primary = false;
  }
  {
    id = "glm-4.7-flash";
    name = "GLM-4.7 Flash";
    primary = false;
  }

  # ===== CODING MODELS =====
  {
    id = "qwen2.5-coder:32b";
    name = "Qwen 2.5 Coder 32B";
    primary = false;
  }
  {
    id = "qwen2.5-coder:14b";
    name = "Qwen 2.5 Coder 14B";
    primary = false;
  }
  {
    id = "qwen2.5-coder:7b";
    name = "Qwen 2.5 Coder 7B";
    primary = false;
  }
  {
    id = "qwen2.5-coder:3b";
    name = "Qwen 2.5 Coder 3B";
    primary = false;
  }

  # ===== MEDIUM & GENERAL PURPOSE (7B) =====
  {
    id = "qwen2.5:7b";
    name = "Qwen 2.5 7B";
    primary = false;
  }
  {
    id = "mistral:7b";
    name = "Mistral 7B";
    primary = false;
  }

  # ===== LIGHT / SMALL (≤ 3B) =====
  {
    id = "qwen2.5:3b";
    name = "Qwen 2.5 3B";
    primary = false;
  }
  {
    id = "phi3:mini";
    name = "Phi 3 Mini (~3.8B)";
    primary = false;
  }
  {
    id = "gemma3:1b";
    name = "Gemma 3 1B";
    primary = false;
  }
  {
    id = "gemma3:270m";
    name = "Gemma 3 270M";
    primary = false;
  }

  # ===== ULTRA LIGHT / EMBEDDINGS =====
  {
    id = "all-minilm:latest";
    name = "All-MiniLM (Embedding)";
    primary = false;
  }
]
