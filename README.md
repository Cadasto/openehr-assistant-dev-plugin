# openEHR Assistant Dev Plugin

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/github/v/release/Cadasto/openehr-assistant-dev-plugin?label=version)](https://github.com/Cadasto/openehr-assistant-dev-plugin/releases)
[![Claude Code](https://img.shields.io/badge/Claude_Code-plugin-D97757?logo=anthropic&logoColor=white)](https://claude.ai/code)
[![Cursor](https://img.shields.io/badge/Cursor-plugin-000?logo=cursor&logoColor=white)](https://cursor.com)
[![Keep a Changelog](https://img.shields.io/badge/Keep%20a%20Changelog-1.1.0-E05735)](CHANGELOG.md)

A maintainer plugin by **Cadasto B.V.** for the people who build the openEHR Assistant tooling: the **[openehr-assistant-mcp](https://github.com/cadasto/openehr-assistant-mcp)** server and the user-facing **[openehr-assistant-plugin](https://github.com/cadasto/openehr-assistant-plugin)** for Claude Code and Cursor. It helps them **design, implement, test, document, and release** new MCP tools, prompts, resources, guides, completion providers, and examples, and keep the two repositories version-aligned. It adds four skills, one agent, a session-start hook, and a Cursor rule, shared by **Claude Code** and **Cursor** from one component set.

The plugin owns the authoring and release workflow for those two repositories: which conventions apply where, how to add an artefact correctly, and how to test it in the MCP server's Docker dev container. It is **not** an end-user clinical tool. Clinical modelling, archetype and template authoring, AQL, and CKM discovery belong to the user-facing [openehr-assistant-plugin](https://github.com/cadasto/openehr-assistant-plugin); install that one to *use* openEHR, and this one to *build* the tooling. Nor does it replace the target repositories' own conventions: each skill reads that repository's `AGENTS.md` first and treats it as authoritative.

**Requirements.** A Claude Code or Cursor host, and a checkout of the repository you are working on. Work in openehr-assistant-mcp also needs Docker: its `php`, `composer`, and PHPUnit commands run only inside the dev container (`make up-dev`), never on the host. Three skills pre-approve openEHR Assistant MCP tools; the plugin bundles no MCP server, so your host resolves them from one you already have configured, typically a local dev instance (see [MCP wiring](#mcp-wiring)). The plugin itself is pure Markdown + JSON, with no build step.

## Table of contents

- [Features](#features)
- [Installation](#installation)
- [Components](#components)
- [MCP wiring](#mcp-wiring)
- [Contributing](#contributing)
- [Documentation](#documentation)
- [License](#license)

## Features

- **Guide and prompt authoring**: scaffolds implementation guides and MCP prompts with the right header blocks, categories, and policy split.
- **MCP tool authoring**: authors or extends `#[McpTool]`, resources, and completion providers with matching PHPUnit tests, run in the Docker dev container.
- **Example authoring**: adds curated worked examples in the `openehr://examples/{aql|flat|structured|archetypes}` namespace.
- **Release workflow**: version bump, Keep a Changelog curation, manifest sync, and `mcp` ↔ `plugin` compatibility alignment.
- **Repo-aware**: a session hook and a scout agent detect which target repository you are in and surface its conventions and dev commands.

## Installation

**Claude Code**, from the Cadasto marketplace:

```text
/plugin marketplace add Cadasto/plugin-marketplace
/plugin install openehr-assistant-dev@cadasto
```

Or load a local working copy for a single session, while developing:

```bash
claude --plugin-dir /path/to/openehr-assistant-dev-plugin
```

**Cursor**: add the plugin through Cursor's plugin flow, from a Git URL or a local path. The repository includes a Cursor manifest at [`.cursor-plugin/plugin.json`](.cursor-plugin/plugin.json); skills, rules, agents, and hooks are shared with the Claude plugin.

See [docs/install.md](docs/install.md) for marketplace, local-development, update, and Cursor install details.

## Components

### Skills

| Skill | Target repo | Description |
|-------|-------------|-------------|
| `guide-prompt-authoring` | mcp | Author implementation guides (`resources/guides/`) and MCP prompts (`resources/prompts/` + `src/Prompts/`) |
| `mcp-tool-authoring` | mcp | Author or extend MCP tools, resources, and completion providers in `src/`, with PHPUnit tests, in the Docker dev container |
| `example-authoring` | mcp | Author curated worked examples in the `openehr://examples/{kind}/{name}` namespace |
| `release-workflow` | both | Version bump, CHANGELOG curation, manifest sync, and `mcp` ↔ `plugin` compatibility alignment |

### Agents

| Agent | Description |
|-------|-------------|
| `repo-conventions-scout` | Detects which target repository the workspace is (mcp, plugin, or this dev plugin) and returns the applicable layout, conventions, and dev commands |

### Hooks

- **SessionStart**: detects the target repository and prints the applicable skills and dev commands; in openehr-assistant-mcp it adds the Docker-only reminder. It prints nothing in any other repository.

### Cursor rule

- **`dev-context.mdc`**: Cursor-only guidance, scoped to the target repositories' key files, to read the target repository's `AGENTS.md` first and use this plugin's authoring skills.

## MCP wiring

This plugin does **not** bundle a `.mcp.json`. Maintainers test against a **local** MCP server (`make up-dev` exposes `streamable-http` on `:8343`, or use `stdio`), not the hosted production instance. Skill `allowed-tools` reference `mcp__openehr-assistant__*` tools; your host resolves them from whatever openEHR Assistant MCP server you already have configured (the user-facing plugin or a local dev instance).

To point at a local server, add an `.mcp.json` of your own:

```json
{
  "mcpServers": {
    "openehr-assistant": { "type": "streamable-http", "url": "http://localhost:8343/" }
  }
}
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for maintainer workflows and [AGENTS.md](AGENTS.md) for the full conventions used by AI assistants in this repository. Before opening a PR, run both checks:

```bash
./scripts/validate.sh        # manifests, dual-host parity, frontmatter
claude plugin validate .     # manifest + component structure
```

`validate.sh` warns and skips if Python is not installed; CI runs the full check. See [CHANGELOG.md](CHANGELOG.md) for release notes.

## Documentation

| Doc | Purpose |
|-----|---------|
| [docs/install.md](docs/install.md) | Install and update on Claude Code and Cursor |
| [docs/testing.md](docs/testing.md) | Validation (`scripts/validate.py`) and local triggering tests |
| [docs/versioning.md](docs/versioning.md) | SemVer policy and release steps |
| [docs/skill-authoring.md](docs/skill-authoring.md) | Skill and agent authoring conventions (the lean description pattern) |

## License

[MIT License](LICENSE)
