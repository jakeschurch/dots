{ lib, ... }:
{
  mkOpencodeAgentMarkdown =
    agentName:
    { prompt, ... }@attrs:
    let
      frontMatterAttrs = lib.filterAttrs (k: _: k != "prompt") attrs;
      content = ''
        ---
        ${lib.concatMapStringsSep "\n" (k: v: "${k}: ${lib.toJSON v}") (lib.attrValues frontMatterAttrs)}
        ---

        ${prompt}
      '';
    in
    {
      home.file."config/opencode/agents/${agentName}.md".text = content;
    };
}
