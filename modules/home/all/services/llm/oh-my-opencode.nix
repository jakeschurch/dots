{ }:
let
  # Helper to get model ID by a predicate

  # Model tiers for different agent needs
  heavy = "nvidia/qwen2.5-coder:14b"; # 14B+ for complex reasoning
  medium = "nvidia/qwen2.5-coder:7b"; # 7B for balanced tasks
  light = "nvidia/qwen2.5:3b"; # 3B for fast/simple tasks
  reasoning = "nvidia/qwen2.5:14b"; # Non-coder for planning/reasoning

  cfg = {
    "$schema" =
      "https://raw.githubusercontent.com/code-yeongyu/oh-my-opencode/master/assets/oh-my-opencode.schema.json";

    # Use local Ollama for all agents
    agents = {
      # Main orchestrator - needs strongest model
      sisyphus = {
        model = heavy;
        temperature = 0.7;
      };

      sisyphus-junior = {
        model = medium;
        temperature = 0.7;
      };

      # Planner for task decomposition
      prometheus = {
        model = reasoning;
        temperature = 0.5;
      };

      # Architecture and debugging
      oracle = {
        model = heavy;
        temperature = 0.3;
      };

      # Documentation and codebase search
      librarian = {
        model = medium;
        temperature = 0.2;
      };

      # Fast codebase exploration
      explore = {
        model = light;
        temperature = 0.1;
      };

      # Build/execution tasks
      build = {
        model = medium;
        temperature = 0.2;
      };

      OpenCode-Builder = {
        model = medium;
        temperature = 0.2;
      };

      # Planning
      plan = {
        model = reasoning;
        temperature = 0.5;
      };

      # Wisdom/strategy
      metis = {
        model = reasoning;
        temperature = 0.5;
      };

      # Code review/criticism
      momus = {
        model = medium;
        temperature = 0.3;
      };

      # Visual analysis (use llama for multimodal)
      multimodal-looker = {
        model = "nvidia/llama3.1:8b";
        temperature = 0.3;
      };

      # Heavy lifting tasks
      atlas = {
        model = heavy;
        temperature = 0.5;
      };
    };

    # Model categories for fallback/defaults
    categories = {
      heavy = {
        description = "Complex reasoning and code generation";
        model = heavy;
        temperature = 0.7;
      };
      medium = {
        description = "Balanced tasks";
        model = medium;
        temperature = 0.5;
      };
      light = {
        description = "Fast, simple tasks";
        model = light;
        temperature = 0.3;
      };
      reasoning = {
        description = "Planning and architecture";
        model = reasoning;
        temperature = 0.5;
      };
    };

    # Disable hooks that might cause issues with local models
    disabled_hooks = [
      "auto-update-checker"
      "anthropic-context-window-limit-recovery"
    ];

    # Git commit settings
    git_master = {
      commit_footer = true;
      include_co_authored_by = false; # Local models don't need attribution
    };
  };
in
{
  home.file.".config/opencode/oh-my-opencode.json".text = builtins.toJSON cfg;
}
