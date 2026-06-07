#!/usr/bin/env bash
# SessionStart hook (openEHR Assistant Dev Plugin):
# Detect which openEHR Assistant repo the workspace is and surface the
# applicable maintainer workflow + dev commands. Non-blocking; output is
# injected as session context.

set -euo pipefail

repo="unknown"

# --- MCP server repo: openehr-assistant-mcp with attribute-driven discovery ---
if [ -f "composer.json" ] && grep -q "Cadasto\\\\OpenEHR\\\\MCP\\\\Assistant" composer.json 2>/dev/null; then
  repo="mcp"
elif [ -f "public/index.php" ] && [ -d "src/Tools" ]; then
  repo="mcp"
fi

# --- Plugin repos: distinguished by plugin.json name ---
if [ "$repo" = "unknown" ] && [ -f ".claude-plugin/plugin.json" ]; then
  if grep -q '"openehr-assistant-dev"' .claude-plugin/plugin.json 2>/dev/null; then
    repo="dev"
  elif grep -q '"openehr-assistant"' .claude-plugin/plugin.json 2>/dev/null; then
    repo="plugin"
  fi
fi

case "$repo" in
  mcp)
    echo "openEHR Assistant Dev — target repo: openehr-assistant-mcp (MCP server)"
    echo ""
    echo "Authoring skills: guide-prompt-authoring, mcp-tool-authoring, example-authoring"
    echo "Release: release-workflow"
    echo ""
    echo "Docker-only runtime — no local PHP/Composer. Use the dev container:"
    echo "  make up-dev      # start dev containers"
    echo "  make install     # install Composer deps"
    echo "  docker compose -f .docker/docker-compose.yml -f .docker/docker-compose.dev.yml exec -u 1000:1000 app composer test"
    echo "  make conformance # MCP conformance suite (server must be up)"
    ;;
  plugin)
    echo "openEHR Assistant Dev — target repo: openehr-assistant-plugin (Claude + Cursor plugin)"
    echo ""
    echo "Pure markdown + JSON, no build step. Components: skills/, commands/, agents/, hooks/."
    echo "Keep .claude-plugin and .cursor-plugin versions in sync; update AGENTS.md, README.md, hooks/session-start.sh when adding components."
    echo "Release: release-workflow"
    ;;
  dev)
    echo "openEHR Assistant Dev — you are in the dev plugin repo itself."
    echo "Skills: guide-prompt-authoring, mcp-tool-authoring, example-authoring, release-workflow. Agent: repo-conventions-scout."
    ;;
  *)
    # Not a recognised openEHR Assistant repo — stay silent to avoid noise.
    :
    ;;
esac
