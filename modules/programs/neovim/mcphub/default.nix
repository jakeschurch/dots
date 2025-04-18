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

      sequentialthinking = {
        command = "docker";
        args = [
          "run"
          "--rm"
          "-i"
          "mcp/sequentialthinking"
        ];
      };

      memory = {
        command = "docker";
        args = [
          "run"
          "-i"
          "-v"
          "claude-memory:/app/dist"
          "--rm"
          "mcp/memory"
        ];
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
