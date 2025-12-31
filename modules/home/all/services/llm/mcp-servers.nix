{
  web-search = {
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
    description = "notion mcp server";
    url = "https://mcp.notion.com/mcp";
  };

  kubernetes-mcp = {
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
    description = "datadog logs, metrics, and monitors for incident management";
    cmd = [
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
    description = "GitHub repository management and operations";
    url = "https://api.githubcopilot.com/mcp/";
    headers = {
      Authorization = "Bearer ";
    };
  };
}
