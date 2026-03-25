{ flake, pkgs, ... }:
let
  inherit (flake) inputs;
in

{
  home.packages = with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
    claude-code
    oh-my-opencode
    claude-code-acp
    claude-plugins
    agent-deck
  ];
}
