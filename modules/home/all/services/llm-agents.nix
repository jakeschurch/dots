{
  config,
  flake,
  lib,
  pkgs,
  ...
}:
let
  inherit (flake) inputs;

  cavemanBlock = pkgs.writeText "caveman-global.md" ''
    <!-- BEGIN CAVEMAN GLOBAL -->
    ## Caveman Mode

    Terse like caveman. Technical substance exact. Only fluff die.
    Drop: articles, filler, pleasantries, hedging.
    Fragments OK. Short synonyms. Code unchanged.
    Pattern: [thing] [action] [reason]. [next step].
    ACTIVE EVERY RESPONSE. No revert after many turns. No filler drift.
    Code/commits/PRs: normal. Off: "stop caveman" / "normal mode".
    <!-- END CAVEMAN GLOBAL -->
  '';
in
{
  home.packages = with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
    claude-code
    claude-plugins
    agent-deck
    codex
    pi
  ];

  home.activation.enable-caveman-for-agents = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    start='<!-- BEGIN CAVEMAN GLOBAL -->'
    end='<!-- END CAVEMAN GLOBAL -->'

    for file in \
      "${config.home.homeDirectory}/CLAUDE.md" \
      "${config.home.homeDirectory}/AGENTS.md" \
      "${config.home.homeDirectory}/GEMINI.md"
    do
      mkdir -p "$(dirname "$file")"
      touch "$file"
      ${pkgs.gnused}/bin/sed -i "/$start/,/$end/d" "$file"
      if [ -s "$file" ]; then
        printf '\n' >> "$file"
      fi
      cat ${cavemanBlock} >> "$file"
    done

    agents_skills_dir="${config.home.homeDirectory}/.agents/skills"
    codex_skills_dir="${config.home.homeDirectory}/.codex/skills"
    mkdir -p "$agents_skills_dir"
    for skill in caveman caveman-commit caveman-review caveman-compress caveman-help caveman-stats; do
      source="$codex_skills_dir/$skill"
      target="$agents_skills_dir/$skill"
      if [ -e "$source" ]; then
        if [ -e "$target" ] && [ ! -L "$target" ]; then
          echo "skip existing non-symlink $target"
        else
          ln -sfn "$source" "$target"
        fi
      fi
    done

    pi_settings="${config.home.homeDirectory}/.pi/agent/settings.json"
    mkdir -p "$(dirname "$pi_settings")"
    if [ ! -f "$pi_settings" ]; then
      printf '{}\n' > "$pi_settings"
    fi
    tmp="$(${pkgs.coreutils}/bin/mktemp)"
    ${pkgs.jq}/bin/jq '
      .skills = (((.skills // []) + ["~/.agents/skills", "~/.codex/skills"]) | unique)
      | .enableSkillCommands = true
    ' "$pi_settings" > "$tmp"
    mv "$tmp" "$pi_settings"
  '';
}
