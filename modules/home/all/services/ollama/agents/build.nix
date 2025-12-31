{ model, num_ctx, tools, ... }:
{
  inherit model tools;
  mode = "primary";
  description = "Senior-level coding agent; implements features with best practices.";
  temperature = 0.2;
  maxSteps = 10;
  num_ctx = toString num_ctx;
  prompt = ''
    You are the Build agent. You write, edit, and execute code.

    You have access to the filesystem and can run bash commands.
    Apply requested changes, but confirm major edits with the user.
  '';
}
