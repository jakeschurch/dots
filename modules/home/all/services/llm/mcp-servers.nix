_: {
  web-search = {
    permission = "allow";
    command = [
      "npx"
      "-y"
      "websearch-mcp"
    ];
    env = {
      FASTMCP_LOG_LEVEL = "ERROR";
    };
  };

  notion = {
    permission = "allow";
    description = "notion mcp server";
    url = "https://mcp.notion.com/mcp";
  };

  kubernetes-mcp = {
    permission = "ask";
    description = "k8s mcp server";
    command = [
      "npx"
      "-y"
      "kubernetes-mcp-server@latest"
      "--read-only"
      "--disable-destructive"
    ];
  };

  datadog = {
    permission = "ask";
    description = "datadog logs, metrics, and monitors for incident management";
    command = [
      "npx"
      "-y"
      "@winor30/mcp-server-datadog"
    ];
    envs = { };
    env_keys = [
      "DATADOG_API_KEY"
      "DATADOG_APP_KEY"
      "DATADOG_SUBDOMAIN"
    ];
  };

  github-mcp = {
    permission = "ask";
    description = "GitHub repository management and operations";
    url = "https://api.githubcopilot.com/mcp/";
    headers = {
      Authorization = "Bearer";
    };
  };
}
