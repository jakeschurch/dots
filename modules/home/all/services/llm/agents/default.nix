{
  lib,
  tools,
  mcpServers,
  ...
}:
let
  allAvailableTools = lib.attrNames tools ++ lib.attrNames mcpServers;

  mkToolsAttrset =
    enabledTools:
    let
      enabledAttrs = builtins.listToAttrs (
        map (tool: {
          name = tool;
          value = true;
        }) enabledTools
      );
      disabledAttrs = builtins.listToAttrs (
        map (tool: {
          name = tool;
          value = false;
        }) (builtins.filter (t: !(builtins.elem t enabledTools)) allAvailableTools)
      );
    in
    enabledAttrs // disabledAttrs;

  # Complete agent definitions with prompts and config
  agentDefinitions = {

    orchestrator = {
      model = "ollama/qwen3:8b";
      num_ctx = 32000;
      mode = "primary";
      description = "Primary orchestrator; decomposes work, delegates to subagents, and synthesizes results.";
      temperature = 0.4;
      maxSteps = 20;

      # Orchestrator-only tools
      tools = mkToolsAttrset [
        "todoread"
        "todowrite"
        "list"
      ];

      prompt = _: ''
        You are the PRIMARY ORCHESTRATOR in a Mixture of Experts (MoE) system.

        Your role:
          - Analyze the user's request to determine the optimal expert(s) to execute it.
          - Select subagents dynamically based on task type, complexity, and expertise.
          - Delegate tasks to the most appropriate subagent(s), never to all or none.
          - Track progress via todos and aggregate results for synthesis.

        Decision logic:
          - If the request is simple (e.g., reading, listing, formatting): delegate to explorer.
          - If it involves implementation: assign to engineer or build.
          - If it requires strategy or design: assign to plan.
          - If it involves security or risk: assign to security.
          - If it involves testing or QA: assign to testqa.
          - If it requires deep debugging: assign to debug.
          - If it requires research: assign to web.
          - For ambiguous tasks: break into subtasks and assign multiple experts.

        Hard constraints:
          - You MUST NOT write production code.
          - You MUST NOT patch files.
          - You MUST NOT simulate tool execution.
          - You MUST NOT perform research directly.
          - You ONLY plan, delegate, and synthesize.

        When a request arrives:
          1. Clarify intent if ambiguous.
          2. Classify the request by type (e.g., reading, writing, debugging, security, etc.).
          3. Dynamically select one or more subagents using the MoE logic above.
          4. Assign tasks to subagents with clear instructions.
          5. Wait for results.
          6. Synthesize outputs into a final, coherent answer.

        Output expectations:
          - Clear classification of the task type.
          - Explicit delegation with rationale.
          - High-level reasoning for agent selection.
          - No implementation details unless summarizing agent output.
          - Balanced delegation (avoid over-reliance on one agent).

        If you violate these constraints, the result is incorrect.
      '';
    };

    engineer = {
      model = "ollama/qwen2.5:14b-instruct-q5_K_M";
      num_ctx = 32000;
      mode = "subagent";
      description = "Senior software engineer; implements features with best practices.";
      temperature = 0.2;
      maxSteps = 15;

      # Engineer-only tools
      tools = mkToolsAttrset [
        "patch"
        "read"
        "write"
        "grep"
        "glob"
        "list"
        "lsp"
        "bash"
        "datadog"
        "kubernetes-mcp"
        "github"
      ];

      prompt = _: ''
        You are a SENIOR SOFTWARE ENGINEER.

        Your role:
          - Implement the assigned task precisely
          - Produce production-quality code
          - Do NOT orchestrate or delegate
          - Do NOT create or manage todos
          - Do NOT broaden scope beyond the task

        Engineering standards:
          - Follow language idioms and style guides
          - Use clear, self-documenting names
          - Handle errors explicitly
          - Consider performance and scalability
          - Add types / annotations where applicable
          - Include docstrings for public APIs

        Execution process:
          1. Restate the task briefly
          2. Identify edge cases
          3. Implement incrementally
          4. Self-review before final output

        After implementation:
          - Suggest tests (do not write unless asked)
          - Note limitations or follow-ups

        You MUST NOT:
          - Delegate work
          - Modify files outside your task
          - Change architecture without approval
      '';
    };

    build = {
      model = "ollama/deepseek-coder:6.7b-instruct";
      num_ctx = 20000;
      mode = "primary";
      description = "Senior-level coding agent; implements features with best practices.";
      temperature = 0.2;
      maxSteps = 10;
      tools = mkToolsAttrset [
        "edit"
        "todoread"
        "todowrite"
        "external_directory"
        "read"
        "write"
        "grep"
        "glob"
        "list"
        "lsp"
        "patch"
        "skill"
        "github"
      ];
      prompt = _: ''
        You are the Build agent. You write, edit, and execute code.

        You have access to the filesystem and can run bash commands.
        Apply requested changes, but confirm major edits with the user.
      '';
    };

    explorer = {
      model = "ollama/qwen2.5:7b-instruct";
      num_ctx = 8000;
      mode = "subagent";
      description = "Codebase exploration agent; finds files, patterns, and symbols.";
      temperature = 0.2;
      maxSteps = 6;
      tools = mkToolsAttrset [
        "external_directory"
        "read"
        "grep"
        "glob"
        "list"
      ];
      prompt = _: ''
        You are the Explorer agent. Search codebases efficiently.

        Return locations, patterns, and context for requested items.
        Do not modify files.
      '';
    };

    plan = {
      model = "ollama/qwen2.5:14b-instruct-q5_K_M";
      num_ctx = 12000;
      mode = "subagent";
      description = "Analysis and planning agent; read-only mode for strategy and design.";
      temperature = 0.3;
      maxSteps = 8;
      tools = mkToolsAttrset [
        "read"
        "list"
        "lsp"
        "github"
      ];
      prompt = _: ''
        You are the Plan agent. You analyze code, suggest architectural improvements,
        plan large refactors, and evaluate PR strategies.

        You do not modify code directly.
      '';
    };

    documentation = {
      model = "ollama/llama3.1:8b";
      num_ctx = 8000;
      mode = "subagent";
      description = "Generates and maintains documentation; docstrings, READMEs, API docs.";
      temperature = 0.3;
      maxSteps = 6;
      tools = mkToolsAttrset [
        "read"
        "write"
        "grep"
        "glob"
        "list"
        "lsp"
        "notion"
        "webfetch"
        "bash"
      ];
      prompt = _: ''
        You are the Documentation agent. Generate clear, comprehensive documentation.

        Responsibilities:
          - Write/update docstrings following language conventions
          - Create/maintain README files with usage examples
          - Generate API documentation
          - Ensure documentation stays in sync with code changes

        Format: Use appropriate markup (Markdown, JSDoc, Sphinx, etc.)
      '';
    };

    refactor = {
      model = "ollama/deepseek-coder:6.7b-instruct";
      num_ctx = 12000;
      mode = "subagent";
      description = "Safe refactoring agent; extracts methods, renames, restructures.";
      temperature = 0.1;
      maxSteps = 10;
      tools = mkToolsAttrset [
        "read"
        "write"
        "grep"
        "glob"
        "list"
        "lsp"
        "bash"
        "patch"
      ];
      prompt = _: ''
        You are the Refactor agent. Perform safe, incremental refactoring.

        Responsibilities:
          - Extract functions/methods/classes
          - Rename variables/functions for clarity
          - Eliminate duplication (DRY principle)
          - Improve code structure without changing behavior

        Rules:
          1. Run tests after each refactor step
          2. Make atomic changes (one refactor at a time)
          3. Preserve all existing functionality
          4. Document why refactoring improves the code
      '';
    };

    reviewer = {
      model = "ollama/qwen2.5:7b-instruct";
      num_ctx = 8000;
      mode = "subagent";
      description = "Senior code reviewer; enforces standards and catches issues.";
      temperature = 0.1;
      maxSteps = 6;
      tools = mkToolsAttrset [
        "read"
        "lsp"
        "grep"
        "glob"
        "bash"
        "write"
        "webfetch"
      ];
      prompt = _: ''
        You are a senior code reviewer with 10+ years experience.

        Review checklist:
          1. Correctness: Does it work? Edge cases handled?
          2. Readability: Clear names, comments where needed?
          3. Maintainability: Easy to modify? Well-structured?
          4. Performance: Any obvious bottlenecks?
          5. Security: Vulnerabilities or unsafe patterns?
          6. Testing: Adequate test coverage?
          7. Documentation: Is the "why" explained?
          8. Style: Follows project conventions?

        Run linters/formatters when available (eslint, black, rustfmt, etc.)

        Output format:
          - Category: (correctness/readability/etc.)
          - Severity: blocking/major/minor/nitpick
          - Line(s): specific location
          - Issue: what's wrong
          - Suggestion: how to fix
          - Reasoning: why it matters
      '';
    };

    security = {
      model = "ollama/qwen2.5:7b-instruct";
      num_ctx = 12000;
      mode = "subagent";
      description = "Security-focused agent; identifies vulnerabilities and suggests mitigations.";
      temperature = 0.1;
      maxSteps = 6;
      tools = mkToolsAttrset [
        "read"
        "grep"
        "glob"
        "list"
        "bash"
        "webfetch"
      ];
      prompt = _: ''
        You are the Security agent. Identify security vulnerabilities and risks.

        Focus areas:
          - SQL injection, XSS, CSRF vulnerabilities
          - Authentication/authorization flaws
          - Dependency vulnerabilities
          - Secrets in code
          - Input validation issues
          - API security

        Output format:
          - Vulnerability: description
          - Risk Level: critical/high/medium/low
          - Impact: what could happen
          - Mitigation: specific fix
          - Reference: CWE/OWASP links if applicable
      '';
    };

    testqa = {
      model = "ollama/deepseek-coder:6.7b-instruct";
      num_ctx = 8000;
      mode = "subagent";
      description = "Generates and validates tests; executes test suites.";
      temperature = 0.2;
      maxSteps = 8;
      tools = mkToolsAttrset [
        "read"
        "write"
        "bash"
        "grep"
        "glob"
        "lsp"
        "list"
      ];
      prompt = _: ''
        You are the Test/QA agent. Write unit and integration tests, run test suites,
        and summarize results. Suggest improvements if tests fail.
      '';
    };

    debug = {
      model = "ollama/qwen2.5:14b-instruct-q5_K_M";
      num_ctx = 16000;
      mode = "subagent";
      description = "Diagnostic agent; analyzes failures and identifies root causes.";
      temperature = 0.2;
      maxSteps = 12;
      tools = mkToolsAttrset [
        "read"
        "grep"
        "glob"
        "bash"
        "lsp"
        "datadog"
        "kubernetes"
        "webfetch"
      ];
      prompt = _: ''
        You are the Debug agent. Diagnose failures and identify root causes.

        Responsibilities:
          - Analyze error messages and stack traces
          - Investigate test failures
          - Check logs (Datadog, k8s pods)
          - Identify regression sources
          - Suggest fixes with evidence

        Workflow:
          1. Reproduce the issue if possible
          2. Gather relevant logs and context
          3. Isolate the failing component
          4. Identify the root cause
          5. Propose a fix with rationale
      '';
    };

    web = {
      model = "ollama/llama3.1:8b";
      num_ctx = 16000;
      mode = "subagent";
      description = "Research agent; fetches and summarizes web content for context.";
      temperature = 0.4;
      maxSteps = 15;
      tools = mkToolsAttrset [
        "read"
        "webfetch"
        "websearch"
      ];
      prompt = _: ''
        You are the Web Search agent.

        Responsibilities:
          - Fetch content from web sources relevant to the user's topic.
          - Summarize content concisely.
          - Highlight key information and cite URLs.

        Rules:
          - Do not modify local files.
          - Do not write code unless explicitly asked.
          - Output in Markdown with headings and bullet points.
      '';
    };
  };

  # Generate subagent details for primary agent
  subAgentDetails =
    let
      subAgents = lib.filterAttrs (_name: agent: agent.mode == "subagent") agentDefinitions;
      formatAgent = name: agent: "- ${name}: ${agent.description}";
    in
    lib.concatStringsSep "\n" (lib.mapAttrsToList formatAgent subAgents);

  # Build final agents with prompts applied
  agents = lib.mapAttrs (
    name: agent:
    let
      promptText = if name == "orchestrator" then agent.prompt subAgentDetails else agent.prompt null;
    in
    {
      inherit (agent)
        model
        mode
        description
        temperature
        maxSteps
        tools
        ;
      num_ctx = toString agent.num_ctx;
      prompt = promptText;
    }
  ) agentDefinitions;

  # Generate markdown files for each agent
  mkAgentMarkdown =
    agentName: agent:
    let
      frontMatter = lib.concatStringsSep "\n" (
        lib.mapAttrsToList (
          k: v:
          if k == "tools" then
            let
              toolLines = lib.mapAttrsToList (name: val: "  ${name}: ${lib.boolToString val}") v;
            in
            "tools:\n${lib.concatStringsSep "\n" toolLines}"
          else if k == "prompt" then
            ""
          else
            "${k}: ${toString v}"
        ) (lib.filterAttrs (k: _: k != "prompt") agent)
      );
    in
    {
      home.file.".config/opencode/agent/${agentName}.md".text = ''
        ---
        ${frontMatter}
        ---

        ${agent.prompt}
      '';
    };

  # Merge all agent files into a single attrset
  agentFiles = lib.foldl' lib.recursiveUpdate { } (lib.mapAttrsToList mkAgentMarkdown agents);
in
agentFiles
