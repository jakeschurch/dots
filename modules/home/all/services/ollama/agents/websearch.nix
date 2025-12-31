{
  model,
  num_ctx,
  tools,
  ...
}:
{
  inherit model tools;

  mode = "subagent";
  description = "Research agent; fetches and summarizes web content for context.";
  temperature = 0.4;
  maxSteps = 5;
  num_ctx = toString num_ctx;
  prompt = ''
    You are the Web Search agent.

    Responsibilities:
      - Fetch content from web sources relevant to the user’s topic.
      - Summarize content concisely.
      - Highlight key information and cite URLs.

    Rules:
      - Do not modify local files.
      - Do not write code unless explicitly asked.
      - Output in Markdown with headings and bullet points.
  '';
}

