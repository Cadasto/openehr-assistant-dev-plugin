# openEHR Assistant Dev Plugin

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-0.1.0-blue)](CHANGELOG.md)
[![Claude Code](https://img.shields.io/badge/Claude_Code-plugin-D97757?logo=anthropic&logoColor=white)](https://claude.ai/code)
[![Cursor](https://img.shields.io/badge/Cursor-plugin-000?logo=cursor&logoColor=white)](https://cursor.com)
[![Keep a Changelog](https://img.shields.io/badge/Keep%20a%20Changelog-1.1.0-E05735)](CHANGELOG.md)

**Maintainer** plugin for the openEHR Assistant ecosystem. It helps developers **design, implement, test, document, and release** new MCP tools, prompts, resources, guides, completion providers, and examples for the two sibling projects:

- **[openehr-assistant-mcp](https://github.com/cadasto/openehr-assistant-mcp)** — the PHP 8.4 MCP server.
- **[openehr-assistant-plugin](https://github.com/cadasto/openehr-assistant-plugin)** — the user-facing Claude Code + Cursor plugin.

> This is **not** an end-user clinical tool. For clinical modelling, archetype/template authoring, AQL, and CKM discovery, install the user-facing **[openehr-assistant-plugin](https://github.com/cadasto/openehr-assistant-plugin)** instead. This plugin is for people *building* that tooling.

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Components](#components)
- [MCP wiring](#mcp-wiring)
- [Contributing](#contributing)
- [License](#license)

---

## Features

- **Guide & prompt authoring** — scaffolds implementation guides and MCP prompts with the right header blocks, categories, and policy split.
- **MCP tool authoring** — author/extend `#[McpTool]`, resources, and completion providers with matching PHPUnit tests, run via the Docker dev container.
- **Example authoring** — add curated worked examples in the `openehr://examples/{aql|flat|structured|archetypes}` namespace.
- **Release workflow** — version bump, Keep-a-Changelog curation, manifest sync, and `mcp` ↔ `plugin` compatibility alignment.
- **Repo-aware** — a session hook and a scout agent detect which target repo you're in and surface the applicable conventions and dev commands.

---

## Installation

**Claude Code**

```bash
claude plugin add cadasto/openehr-assistant-dev-plugin
```

**Cursor** — Add the plugin via Cursor's plugin flow (Git URL or local path). The repo includes a Cursor manifest at [`.cursor-plugin/plugin.json`](.cursor-plugin/plugin.json); skills, rules, agents, and hooks are shared with the Claude plugin.

Install from a local path while developing:

```bash
claude plugin add /path/to/openehr-assistant-dev-plugin
```

---

## Components

### Skills

| Skill | Target repo | Description |
|-------|-------------|-------------|
| `guide-prompt-authoring` | mcp | Author implementation guides (`resources/guides/`) and MCP prompts (`resources/prompts/` + `src/Prompts/`) |
| `mcp-tool-authoring` | mcp | Author/extend MCP tools, resources, and completion providers in `src/`, with PHPUnit tests, via the Docker dev container |
| `example-authoring` | mcp | Author curated worked examples in the `openehr://examples/{kind}/{name}` namespace |
| `release-workflow` | both | Version bump, CHANGELOG curation, manifest sync, and `mcp` ↔ `plugin` compatibility alignment |

### Agents

| Agent | Description |
|-------|-------------|
| `repo-conventions-scout` | Detects which target repo the workspace is (mcp / plugin / dev) and returns the applicable layout, conventions, and dev commands |

### Hooks

- **SessionStart** — detects the target repo and prints the applicable dev commands plus the Docker-only reminder.

---

## MCP wiring

This plugin does **not** bundle a `.mcp.json`. Maintainers test against a **local** MCP server (`make up-dev` exposes `streamable-http` on `:8343`, or use `stdio`), not the hosted production instance. Skill `allowed-tools` reference `mcp__openehr-assistant__*` tools; your host resolves them from whatever openEHR Assistant MCP server you already have configured (the user-facing plugin or a local dev instance).

To point at a local server, add an `.mcp.json` of your own, e.g.:

```json
{
  "mcpServers": {
    "openehr-assistant": { "type": "streamable-http", "url": "http://localhost:8343/" }
  }
}
```

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for maintainer workflows and [AGENTS.md](AGENTS.md) for the full conventions used by AI assistants in this repo. See [CHANGELOG.md](CHANGELOG.md) for release notes.

---

## License

[MIT License](LICENSE) — Cadasto B.V.
