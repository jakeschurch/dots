{ pkgs, ... }:
{

  home.packages = with pkgs; [
    mcp-hub
    python312Packages.uv
  ];

  home.file.".config/mcphub/servers.json".text = builtins.toJSON {
    mcpServers = {
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

      "github.com/modelcontextprotocol/servers/tree/main/src/filesystem" = {
        command = "docker";
        args = [
          "run"
          "-i"
          "--rm"
          "--mount"
          "type=bind,src=/Users/jake/Projects/work/,dst=/Users/jake/Projects/work/"
          "mcp/filesystem"
          "/Users/jake/Projects/work/"
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

      "github.com/modelcontextprotocol/servers/tree/main/src/memory" = {
        command = "npx";
        args = [
          "-y"
          "@modelcontextprotocol/server-memory"
        ];
        env = {
          MEMORY_FILE_PATH = "~/.mcphub/memory.json";
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
}
