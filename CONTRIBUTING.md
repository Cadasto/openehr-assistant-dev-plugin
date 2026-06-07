# Contributing to openehr-assistant-dev-plugin

Thank you for your interest in contributing! This plugin is **maintainer tooling** for the openEHR Assistant ecosystem. It helps developers author and release artefacts for the [openehr-assistant-mcp](https://github.com/cadasto/openehr-assistant-mcp) server and the [openehr-assistant-plugin](https://github.com/cadasto/openehr-assistant-plugin).

## Table of contents
- [Project setup](#project-setup)
- [Plugin structure](#plugin-structure)
- [Repository archives (.gitattributes)](#repository-archives-gitattributes)
- [Adding or modifying components](#adding-or-modifying-components)
- [Testing locally](#testing-locally)
- [Commit messages and pull requests](#commit-messages-and-pull-requests)
- [Versioning](#versioning)
- [Security](#security)

## Project setup

Prerequisites:
- [Claude Code](https://claude.ai/code) CLI and/or [Cursor](https://cursor.com).

Clone and install:
```bash
git clone <your-fork-url>
cd openehr-assistant-dev-plugin
claude plugin add .
```

No build step is required — the plugin is pure markdown and JSON.

## Plugin structure

```
.claude-plugin/plugin.json    # Claude Code plugin manifest
.cursor-plugin/plugin.json     # Cursor plugin manifest (same version, component paths)
skills/                        # Authoring + release workflows
  <name>/SKILL.md
agents/                        # Specialized subagents
  <name>.md
hooks/                         # Event hooks
  hooks.json                   # Claude Code SessionStart + cross-host config
  cursor-hooks.json            # Cursor format (hooks.sessionStart)
  session-start.sh             # Shared script (repo detection)
rules/                         # Cursor-only rules (.mdc)
  dev-context.mdc
.gitattributes                 # export-ignore: paths omitted from `git archive` only
```

Key conventions:
- Skills go in `skills/<name>/SKILL.md` with YAML frontmatter.
- Agents go in `agents/<name>.md` with YAML frontmatter.
- This plugin uses the **skills-first** layout — there is no legacy `commands/` directory.
- `allowed-tools` in skill frontmatter pre-approves `mcp__openehr-assistant__<tool>` ids to avoid permission prompts.

## Repository archives (.gitattributes)

[`.gitattributes`](.gitattributes) marks some paths with **`export-ignore`** — excluded from `git archive` (and tooling that respects Git export attributes), but **not** from a normal `git clone` or checkout of `main`. Currently omitted from archives: `AGENTS.md`, `CONTRIBUTING.md`, `.github/**`. Prefer **`git clone`** when developing so you keep maintainer docs and GitHub metadata.

## Adding or modifying components

### Skills
- Each skill targets the `mcp` repo, the `plugin` repo, or both — state this in the skill body.
- Skills must defer to the **target repo's own `AGENTS.md`**, which is authoritative; this plugin's skills summarise and operationalise those conventions.
- Use progressive disclosure: mandatory preparation steps first, then detailed guidance.
- List all required MCP tools in `allowed-tools`.

### Agents
- Write a clear system prompt; list the tools the agent needs.
- Keep agents context-isolated and return structured, actionable summaries.

### Hooks
- Keep hook scripts fast — they run on every session start.
- Use `${CLAUDE_PLUGIN_ROOT}` for paths in `hooks.json`.

### Documentation
When adding or renaming components, update all references in:
- `AGENTS.md` (component tables)
- `README.md` (component tables)
- `hooks/session-start.sh` (available-skills list)

## Testing locally

Install from a local path:
```bash
claude plugin add /path/to/openehr-assistant-dev-plugin
```

Verify components work by opening one of the target repos and confirming the SessionStart hook detects it, then invoke a skill (e.g. ask to "create a guide" inside the MCP repo).

## Commit messages and pull requests
- Use [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) (`feat:`, `fix:`, `docs:`, `refactor:`, `chore:`). Scopes: `skills`, `agents`, `hooks`, `rules`, `docs`, `meta`.
- One logical change per PR. Link related issues with GitHub keywords (e.g., `Fixes #123`).

PR checklist:
- [ ] Component works when tested locally with `claude plugin add .`
- [ ] All references updated (AGENTS.md, README.md, hooks)
- [ ] CHANGELOG.md updated
- [ ] No debug code or leftover comments

## Versioning
- Plugin version (and for consistency, description and author) is defined in both `.claude-plugin/plugin.json` and `.cursor-plugin/plugin.json`. Update **both** when releasing.
- Follow Semantic Versioning and maintain `CHANGELOG.md` (Keep a Changelog format).

## Security
Do not open public issues for security vulnerabilities. See [SECURITY.md](SECURITY.md) for the threat model and private reporting process. This project follows the [Code of Conduct](CODE_OF_CONDUCT.md).

Thank you for contributing!
