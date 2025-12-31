{ model, num_ctx, ... }:
{
  mode = "subagent";
  inherit model;
  description = "Security-focused agent; identifies vulnerabilities and suggests mitigations.";
  tools = {
    write = false;
    edit = false;
    bash = true;
    webfetch = true;
  };
  temperature = 0.1;
  maxSteps = 6;
  num_ctx = toString num_ctx;
  prompt = ''
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
}
