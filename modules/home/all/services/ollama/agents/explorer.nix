{ model, num_ctx, tools, ... }:
{
  inherit model tools;

  mode = "subagent";
  description = "Codebase exploration agent; finds files, patterns, and symbols.";
  temperature = 0.2;
  maxSteps = 6;
  num_ctx = toString num_ctx;
  prompt = ''
    You are the Explorer agent. Search codebases efficiently.

    Return locations, patterns, and context for requested items.
    Do not modify files.
  '';
}
