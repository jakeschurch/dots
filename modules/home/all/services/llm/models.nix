_: [
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
]
