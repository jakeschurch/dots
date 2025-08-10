{ pkgs, config, ... }:
{
  home = {

    packages = with pkgs; [
      mcp-hub
      uv
    ];

    file.".config/mcphub/memory.json".source = config.lib.file.mkOutOfStoreSymlink ./memory.json;

    file.".config/mcphub/servers.json".text = builtins.toJSON {

      mcpServers = {

        shortcut = {
          command = "npx";
          args = [
            "-y"
            "@shortcut/mcp@latest"
          ];
        };

        web-search = {
          command = "npx";
          args = [ "websearch-mcp" ];
          env = {
            FASTMCP_LOG_LEVEL = "ERROR";
          };
          disabled = false;
          autoApprove = [ ];
        };

        github = {
          command = "sh";
          args = [
            "-c"
            ''
              exec docker run -i --rm \
                -e GITHUB_PERSONAL_ACCESS_TOKEN="$(gh auth token)" \
                -e GITHUB_READONLY=1 \
                ghcr.io/github/github-mcp-server "$@"
            ''
          ];
        };

        diagram-mcp-server = {
          command = "uvx";
          args = [ "awslabs.aws-diagram-mcp-server" ];
          env = {
            FASTMCP_LOG_LEVEL = "ERROR";
          };
          disabled = false;
          autoApprove = [ ];
        };

        aws-cost-analysis = {
          command = "uvx";
          args = [ "awslabs.cost-analysis-mcp-server@latest" ];
          env = {
            FASTMCP_LOG_LEVEL = "ERROR";
          };
          disabled = false;
          autoApprove = [ ];
        };

        fetch = {
          command = "docker";
          args = [
            "run"
            "-i"
            "--rm"
            "mcp/fetch"
          ];
        };

        awslabsTerraform-mcp-server = {
          command = "uvx";
          args = [ "awslabs.terraform-mcp-server@latest" ];
          env = {
            FASTMCP_LOG_LEVEL = "ERROR";
          };
          disabled = false;
          autoApprove = [ ];
        };

        awslabsAwsDocumentationMcpServer = {
          command = "uvx";
          args = [ "awslabs.aws-documentation-mcp-server@latest" ];
          env = {
            FASTMCP_LOG_LEVEL = "ERROR";
          };
          disabled = false;
          autoApprove = [ ];
        };

        "filesystem" = {
          command = "docker";
          args = [
            "run"
            "-i"
            "--rm"
            "--mount"
            "type=bind,src=/Users/jake/Projects/,dst=/Users/jake/Projects/"
            "mcp/filesystem"
            "/Users/jake/Projects/"
          ];
          disabled = false;
          env = {
            FASTMCP_LOG_LEVEL = "ERROR";
          };
        };

        sequentialthinking = {
          command = "docker";
          args = [
            "run"
            "--rm"
            "-i"
            "mcp/sequentialthinking"
          ];
          env = {
            FASTMCP_LOG_LEVEL = "INFO";
          };
        };

        "memory" = {
          command = "npx";
          args = [
            "-y"
            "@modelcontextprotocol/server-memory"
          ];
          env = {
            MEMORY_FILE_PATH = "${config.xdg.configHome}/mcphub/memory.json";
          };
        };
      };

      nativeMCPServers = {
        neovim = {
          disabled = false;
          disabled_tools = [ ];
          disabled_resources = [ ];
          custom_instructions = {
            disabled = false;
            text = "";
          };
        };
      };
    };
  };
}
