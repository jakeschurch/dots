{ lib, ... }:
let
  mkOpencodeAgentMarkdown =
    agentName:
    { prompt, ... }@attrs:
    let
      frontMatterAttrs = lib.filterAttrs (k: _: k != "prompt") attrs;
      frontMatter = lib.concatStringsSep "\n" (
        lib.mapAttrsToList (k: v: "${k}: ${builtins.toJSON v}") frontMatterAttrs
      );
      content = ''
        ---
        ${frontMatter}
        ---

        ${prompt}
      '';
    in
    {
      home.file.".config/opencode/agents/${agentName}.md".text = content;
    };

  agentFiles = with builtins; filter (fn: fn != "default.nix") (attrNames (readDir ./.));

  agentToolMapping = {
    primary = {
      model = "qwen2.5:14b-instruct-q5_K_M"; # Best model for orchestration
      num_ctx = 32000;
      tools = [
        "todoread"
        "todowrite"
        "list"
        "patch"
      ];
    };

    build = {
      model = "deepseek-coder:6.7b-instruct";
      num_ctx = 20000;
      tools = [
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
    };

    explorer = {
      num_ctx = 8000;
      tools = [
        "external_directory"
        "read"
        "grep"
        "glob"
        "list"
      ];
    };

    plan = {
      num_ctx = 12000;
      model = "qwen2.5:14b-instruct-q5_K_M";
      tools = [
        "read"
        "list"
        "lsp"
        "github"
      ];
    };

    # primary = assert (lib.assertMsg "TODO");

    documentation = {
      num_ctx = 8000;
      model = "llama3.1:8b";
      tools = [
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
    };

    refactor = {
      model = "deepseek-coder:6.7b-instruct";
      num_ctx = 12000;
      tools = [
        "read"
        "write"
        "grep"

        "glob" # Added: find refactor candidates
        "list" # Added: scan directories
        "lsp" # Added: CRITICAL for safe refactoring
        "bash" # Added: run tests after changes
        "patch" # Added: for surgical changes
      ];
    };

    reviewer = {
      model = "qwen2.5:7b-instruct";
      num_ctx = 8000;
      tools = [
        "read"
        "lsp"
        "grep"
        "glob" # Added: review multiple files
        "bash"
        "write" # Added: create review reports
        "webfetch" # Added: check standards
      ];
    };

    security = {
      num_ctx = 12000; # Bumped: for detailed analysis
      model = "qwen2.5:7b-instruct";
      tools = [
        "read"
        "grep"
        "glob" # Added: scan multiple files
        "list" # Added: directory scanning
        "bash" # Added: run security scanners
        "webfetch" # Added: check CVE databases
      ];
    };

    testqa = {
      model = "deepseek-coder:6.7b-instruct";
      num_ctx = 8000;
      tools = [
        "read"
        "write" # Added: CRITICAL - create test files
        "bash" # Added: CRITICAL - run tests
        "grep" # Added: find test patterns
        "glob" # Added: locate test files
        "lsp" # Added: assist test generation
        "list"
      ];
    };

    debug = {
      model = "qwen2.5:14b-instruct-q5_K_M"; # Best reasoning for diagnostics
      num_ctx = 16000;
      tools = [
        "read"
        "grep"
        "glob"
        "bash"
        "lsp"
        "datadog"
        "kubernetes-mcp"
        "webfetch"
      ];
    };

    websearch = {
      model = "qwen3:8b";
      num_ctx = 16000;
      tools = [
        "read"
        "webfetch"
        "websearch"
      ];
    };

  };

  # Import each file and create an attrset
  # The attribute name will be the filename without .nix extension
  agents = builtins.listToAttrs (
    map (fn: {
      name = lib.removeSuffix ".nix" fn;
      value =
        let
          inheritedAttrs = {
            inherit lib;
            inherit
              (agentToolMapping.${lib.removeSuffix ".nix" fn} or {
                num_ctx = 8000;
                tools = [ ];
              }
              )
              num_ctx
              tools
              ;
          };
        in
        import ./${fn} inheritedAttrs;
    }) agentFiles
  );
in
map (agent: mkOpencodeAgentMarkdown agent.name agent.value) agents
