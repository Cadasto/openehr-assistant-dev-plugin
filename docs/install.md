# Installing the openEHR Assistant Dev Plugin

This plugin is distributed for both [Claude Code](https://docs.claude.com/en/docs/claude-code/plugins) (`.claude-plugin/`) and [Cursor](https://cursor.com/docs/plugins) (`.cursor-plugin/`). Skill, agent, and rule content is shared; only the manifest and hook layer differ.

> This is **maintainer tooling**. For end-user openEHR work (archetypes, AQL, CKM), install the user-facing [openehr-assistant](https://github.com/cadasto/openehr-assistant-plugin) plugin instead.

## Claude Code

### Install (from the Cadasto marketplace)

```
/plugin marketplace add cadasto/plugin-marketplace
/plugin install openehr-assistant-dev@cadasto
```

The marketplace name is `cadasto`, so installed plugins are addressed as `<plugin>@cadasto`.

### Load a local working copy (for development)

```bash
claude --plugin-dir /path/to/openehr-assistant-dev-plugin
```

`--plugin-dir` loads the plugin from disk for **that session only** — it does not persist, which makes it the right tool for dogfooding an unreleased working copy. It is repeatable (`--plugin-dir A --plugin-dir B`) and also accepts a `.zip`.

Claude Code has **no `plugin add` subcommand**. `claude plugin install` resolves names from a configured marketplace, not filesystem paths, and `claude plugin marketplace add <path>` expects a marketplace manifest (`.claude-plugin/marketplace.json`) — which a single-plugin repository like this one does not have. For a persistent install, go through the marketplace above.

### Update / inspect

```
/plugin marketplace update cadasto
/plugin update openehr-assistant-dev
```

```bash
claude plugin details openehr-assistant-dev   # component inventory + projected token cost
```

A session restart is required for an update to take effect.

## Cursor

Add this repository as a plugin (Cursor **Settings → Plugins**, via Git URL or local path). The repo root contains `.cursor-plugin/plugin.json`; skills, rules, agents, and the Cursor hook config (`hooks/cursor-hooks.json`) are declared there. After changing content locally, reload or reinstall the plugin so Cursor picks it up.

## MCP wiring

This plugin does **not** bundle a `.mcp.json` — skill `allowed-tools` reference `mcp__openehr-assistant__*` tools, which your host resolves from whatever openEHR Assistant MCP server you already have configured (the user-facing plugin, or a local dev instance). See [AGENTS.md](../AGENTS.md#mcp-wiring).
