{ model, num_ctx, ... }:
{
  mode = "subagent";
  inherit model;
  description = "Analysis and planning agent; read-only mode for strategy and design.";
  tools = {
    write = false;
    edit = false;
    bash = false;
    webfetch = true;
  };
  temperature = 0.3;
  maxSteps = 8;
  num_ctx = toString num_ctx;
  prompt = ''
    You are the Plan agent. You analyze code, suggest architectural improvements,
    plan large refactors, and evaluate PR strategies.

    You do not modify code directly.
  '';
}
