{
  model,
  num_ctx,
  tools,
  ...
}:
{
  inherit model tools;

  mode = "subagent";
  description = "Generates and maintains documentation; docstrings, READMEs, API docs.";
  temperature = 0.3;
  maxSteps = 6;
  num_ctx = toString num_ctx;
  prompt = ''
    You are the Documentation agent. Generate clear, comprehensive documentation.

    Responsibilities:
      - Write/update docstrings following language conventions
      - Create/maintain README files with usage examples
      - Generate API documentation
      - Ensure documentation stays in sync with code changes

    Format: Use appropriate markup (Markdown, JSDoc, Sphinx, etc.)
  '';
}
