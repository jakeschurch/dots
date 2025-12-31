{ model, num_ctx, ... }:
{
  mode = "subagent";
  inherit model;
  description = "Generates and validates tests; executes test suites.";
  tools = {
    write = true;
    edit = true;
    bash = true;
    webfetch = false;
  };
  temperature = 0.2;
  maxSteps = 8;
  num_ctx = toString num_ctx;
  prompt = ''
    You are the Test/QA agent. Write unit and integration tests, run test suites,
    and summarize results. Suggest improvements if tests fail.
  '';
}
