{
  config,
  flake,
  lib,
  pkgs,
  ...
}:
let
  inherit (flake) inputs;

  llmAgents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};

  # agent-deck's TestRuntimeHealthHeadlessWebStartup binds a TCP socket, which
  # the darwin sandbox denies ("bind: operation not permitted"); linux passes
  # because its sandbox netns has loopback up. Normally harmless: numtide
  # prebuilds agent-deck and we substitute it, so the test never runs here.
  #
  # Flip this to true only when numtide has not yet published the version we
  # pin. It skips the test so the build succeeds -- but overrideAttrs changes
  # the output hash, so it also guarantees a cache miss and a ~6min local
  # build on every bump. Flip back once cache.numtide.com catches up.
  skipSandboxUnsafeAgentDeckTests = false;

  agent-deck =
    if skipSandboxUnsafeAgentDeckTests && pkgs.stdenv.hostPlatform.isDarwin then
      llmAgents.agent-deck.overrideAttrs (old: {
        checkFlags = (old.checkFlags or [ ]) ++ [
          "-skip=TestRuntimeHealthHeadlessWebStartup"
        ];
      })
    else
      llmAgents.agent-deck;

  # codex >= 0.159 starts a shared app-server daemon by default, which copies
  # its own package into ~/.codex and requires a codex-package.json beside
  # bin/codex. The nix build ships bare binaries, so every invocation dies with
  # "this CLI has no complete local package". Force the in-process server.
  # Drop once llm-agents.nix ships the packaged layout.
  codex = pkgs.symlinkJoin {
    name = "codex-${llmAgents.codex.version}";
    paths = [ llmAgents.codex ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/codex --add-flags --no-daemon
    '';
  };

  # Serena MCP via uvx. Its Pillow wheel dlopens libz.so.1, which the system
  # NIX_LD_LIBRARY_PATH lacks; extend it here only, not globally.
  serena-mcp = pkgs.writeShellScriptBin "serena-mcp" ''
    export NIX_LD_LIBRARY_PATH="''${NIX_LD_LIBRARY_PATH:+$NIX_LD_LIBRARY_PATH:}${pkgs.zlib}/lib"
    exec ${pkgs.uv}/bin/uvx --from git+https://github.com/oraios/serena serena start-mcp-server "$@"
  '';

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
  home.packages = [
    agent-deck
    llmAgents.claude-code
    llmAgents.claude-plugins
    codex
    pkgs.rtk
    serena-mcp
  ];

  home.activation.enable-caveman-for-agents = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    start='<!-- BEGIN CAVEMAN GLOBAL -->'
    end='<!-- END CAVEMAN GLOBAL -->'

    # Only Claude Code reads the static block; Codex gets caveman from the
    # caveman plugin's SessionStart hook, so strip stale copies elsewhere.
    for file in \
      "${config.home.homeDirectory}/CLAUDE.md" \
      "${config.home.homeDirectory}/AGENTS.md" \
      "${config.home.homeDirectory}/GEMINI.md"
    do
      [ -f "$file" ] || continue
      ${pkgs.gnused}/bin/sed -i "/$start/,/$end/d" "$file"
      if [ ! -s "$file" ] || ! ${pkgs.gnugrep}/bin/grep -q '[^[:space:]]' "$file"; then
        rm -f "$file"
      fi
    done
    file="${config.home.homeDirectory}/CLAUDE.md"
    touch "$file"
    # Drop trailing blank lines so repeated activations don't accumulate them.
    ${pkgs.gnused}/bin/sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$file"
    if [ -s "$file" ]; then
      printf '\n' >> "$file"
    fi
    cat ${cavemanBlock} >> "$file"

    # Standalone caveman skills duplicate the caveman plugin's bundled copies.
    for skill in caveman caveman-commit caveman-review caveman-compress caveman-help caveman-stats cavecrew; do
      link="${config.home.homeDirectory}/.agents/skills/$skill"
      if [ -L "$link" ]; then
        rm -f "$link"
      fi
      rm -rf "${config.home.homeDirectory}/.codex/skills/$skill"
    done
    rmdir --ignore-fail-on-non-empty "${config.home.homeDirectory}/.agents/skills" 2>/dev/null || true
  '';
}
