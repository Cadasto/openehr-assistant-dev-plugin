# AI Guidelines: openEHR Assistant Dev Plugin

This file provides guidance to AI coding assistants working in this repository. It is the canonical instruction source; host-specific files (`.github/copilot-instructions.md`, `rules/dev-context.mdc`, `.claude/CLAUDE.md` if present) delegate here.

## Project Overview

The **openEHR Assistant Dev Plugin** is a **maintainer-facing** AI plugin by Cadasto B.V. It is *not* an end-user clinical tool. Its purpose is to help maintainers **design, implement, test, document, and release** new MCP tools, prompts, resources, guides, completion providers, and examples for the two sibling projects:

- **[openehr-assistant-mcp](https://github.com/cadasto/openehr-assistant-mcp)** — the openEHR Assistant MCP server (tools, prompts, resources, guides, examples, BMM, terminology).
- **[openehr-assistant-plugin](https://github.com/cadasto/openehr-assistant-plugin)** — the user-facing Claude Code + Cursor plugin (skills, commands, agents, hooks) that wraps the MCP server.

This plugin supplies the **authoring and release workflow layer** for those repos: which conventions apply where, how to add an artefact correctly, how to test it in the Docker dev container, and how to keep the two repos version-aligned.

> **Audience boundary.** Do not confuse this plugin with the user-facing one. The user-facing plugin helps clinicians/modellers *use* openEHR (archetypes, AQL, CKM). This plugin helps developers *build the tooling*. Clinical-modelling skills belong in the user-facing plugin, not here.

## The two target repositories

| Repo | Language / Stack | What you author there | Canonical conventions |
|------|------------------|-----------------------|------------------------|
| `openehr-assistant-mcp` | PHP 8.4, `modelcontextprotocol/php-sdk`, Docker | MCP tools (`#[McpTool]`), prompts (`#[McpPrompt]`), resources (`#[McpResourceTemplate]`/`#[McpResource]`), completion providers (`#[CompletionProvider]`), guides (`resources/guides/`), examples (`resources/examples/`), BMM, terminology | that repo's `AGENTS.md` |
| `openehr-assistant-plugin` | Markdown + JSON (no build) | Plugin skills, commands, agents, hooks; dual-host Claude + Cursor manifests | that repo's `AGENTS.md` + `CONTRIBUTING.md` |

**Always read the target repo's own `AGENTS.md` first** when working inside it — it is authoritative for that repo. The skills in this plugin summarise and operationalise those conventions; they do not replace them.

## Components

This plugin uses the **skills-first** layout (no legacy `commands/` directory). All user-invocable workflows are skills.

### Skills (4)
| Skill | Target repo | Purpose |
|-------|-------------|---------|
| `guide-prompt-authoring` | mcp | Author implementation guides (`resources/guides/{category}/{name}.md`) and MCP prompts (`resources/prompts/{name}.md` + `src/Prompts/{Name}.php`). Migrated from the user-facing plugin; the MCP repo's local Cursor copy is the historical seed. |
| `mcp-tool-authoring` | mcp | Author/extend MCP tools, resources, resource templates, and completion providers in `src/`, with matching PHPUnit tests; run them via the Docker dev container. |
| `example-authoring` | mcp | Author curated worked examples in the `openehr://examples/{aql\|flat\|structured\|archetypes}` namespace following the metadata-header conventions. |
| `release-workflow` | both | Version bump, Keep-a-Changelog curation, plugin manifest sync (`.claude-plugin` ↔ `.cursor-plugin`), and `mcp` ↔ `plugin` compatibility alignment. |

### Agents (1)
| Agent | Purpose |
|-------|---------|
| `repo-conventions-scout` | Context-isolated agent that detects which repo the workspace is (mcp / plugin / this dev plugin) and returns the applicable layout, conventions, and dev commands — without polluting the main session with file dumps. |

### Hooks
- **SessionStart** — detects which target repo the workspace is and prints the applicable dev commands + the Docker-only reminder.

## Repository Layout

This repo supports **both Claude Code and Cursor**; shared assets (skills, agents) are used by both. Host-specific manifests and hook configs are separate.

- **Claude manifest**: `.claude-plugin/plugin.json` — name, version, description, author; component discovery uses default folders (`skills/`, `agents/`, `hooks/`).
- **Cursor manifest**: `.cursor-plugin/plugin.json` — name, version, top-level paths (`skills`, `rules`, `agents`, `hooks`).
- **Claude hooks**: `hooks/hooks.json` — array of `{ "type": "SessionStart", ... }`; use `${CLAUDE_PLUGIN_ROOT}` in command paths.
- **Cursor hooks**: `hooks/cursor-hooks.json` — object `{ "hooks": { "sessionStart": [...] } }`; command runs from plugin root.
- **Shared hook script**: `hooks/session-start.sh` — detects the target repo and prints context.
- **Cursor rules**: `rules/` — `.mdc` files (e.g. `dev-context.mdc`) for Cursor-only rule guidance.
- **Skills**: `skills/<name>/SKILL.md`, each with YAML frontmatter (optional `references/` subdir).
- **Agents**: `agents/<name>.md`, each with YAML frontmatter.
- **Claude settings**: `.claude/settings.json` enables the maintainer plugins (skill-creator, superpowers, plugin-dev, claude-md-management); `.claude/CLAUDE.md` imports this file via `@../AGENTS.md`.
- **Validation**: `scripts/validate.sh` (graceful local wrapper — warns and skips if Python is absent) runs `scripts/validate.py`, which checks manifests, dual-host parity, declared paths, and frontmatter. CI pins Python and runs the validator strictly.
- **Docs**: `docs/` holds human-facing install / testing / versioning / skill-authoring references; `.github/` holds issue + PR templates and the validate workflow.

### MCP wiring

This plugin does **not** bundle a `.mcp.json`. Maintainers test against a **local** MCP server (`streamable-http` on `:8343` via `make up-dev`, or `stdio`), not the hosted production instance. Skill `allowed-tools` still reference `mcp__openehr-assistant__*` tools; the host resolves them from whatever openEHR Assistant MCP server the developer already has configured (typically the user-facing plugin or a local dev instance).

### Testing & validating this plugin

No build step — pure Markdown + JSON. Validate and dogfood locally:

```bash
./scripts/validate.sh                                     # manifests, dual-host parity, frontmatter (warns & skips if Python is absent)
claude plugin validate .                                  # manifest + component structure (no Python needed)
claude plugin add /path/to/openehr-assistant-dev-plugin   # install locally
```

Then open one of the target repos and confirm the `SessionStart` hook detects it and the intended skills trigger. This plugin is published in the Cadasto marketplace — once released, users install it with `/plugin install openehr-assistant-dev@cadasto`. Fuller guidance lives in [`docs/`](docs/): [install](docs/install.md), [testing](docs/testing.md), [versioning](docs/versioning.md), and [skill-authoring](docs/skill-authoring.md). CI pins Python and runs `scripts/validate.py` strictly on every push/PR ([`.github/workflows/validate.yml`](.github/workflows/validate.yml)); locally, `scripts/validate.sh` runs the same checks but warns and skips if Python isn't installed.

### Gotchas

- **Cursor hooks use a workspace-relative command** (`bash hooks/session-start.sh`), *not* `${CLAUDE_PLUGIN_ROOT}` — that variable is Claude-Code-only; Cursor resolves hook commands from the plugin root. Keep the two hook configs in step, but do not "fix" the Cursor one to use the Claude variable.
- **MCP discovery is cached** in the server repo. After adding or renaming a tool/resource/prompt class, clear the discovery cache (under `XDG_DATA_HOME`, default `/tmp`) or the new capability won't register — see the `mcp-tool-authoring` skill.
- **`.mcp.json` is intentionally absent** (see *MCP wiring* above) — don't add one pointing at the hosted server.

## Working in the MCP repo (`openehr-assistant-mcp`)

### Docker-only runtime (critical)
There is **no local PHP or Composer** on the host (WSL2 on Windows). All `php`, `composer`, and `vendor/bin/*` commands **must** run inside the dev container, or they will fail.

```bash
make up-dev      # start dev containers (once)
make install     # install Composer dev dependencies
# Tests / static analysis / coverage (dev container, UID 1000):
docker compose -f .docker/docker-compose.yml -f .docker/docker-compose.dev.yml exec -u 1000:1000 app composer test
docker compose -f .docker/docker-compose.yml -f .docker/docker-compose.dev.yml exec -u 1000:1000 app composer check:phpstan
docker compose -f .docker/docker-compose.yml -f .docker/docker-compose.dev.yml exec -u 1000:1000 app composer test:coverage
make conformance # MCP conformance suite over HTTP (server must be up)
```

### Coding standards (mcp repo)
- PSR-12; typed signatures; small methods; PHPDoc only when types aren't self-evident.
- Production namespace `Cadasto\OpenEHR\MCP\Assistant\` (`src/`); tests `…\Tests\` (`tests/`), `*Test.php`.
- **Mock external HTTP** to CKM in tests — never hit live APIs.
- Run `composer test` and `composer check:phpstan` before pushing.

## Working in the plugin repo (`openehr-assistant-plugin`)

- Pure Markdown + JSON; **no build step**.
- Skills `skills/<name>/SKILL.md`; commands `commands/<name>.md`; agents `agents/<name>.md`; all with YAML frontmatter.
- `allowed-tools` pre-approves `mcp__openehr-assistant__<tool>` ids to avoid permission prompts.
- **Guide-First**: skills/commands load relevant MCP guides before acting.
- Dual-host: keep `.claude-plugin/plugin.json` and `.cursor-plugin/plugin.json` versions in sync; Cursor hooks live in `hooks/cursor-hooks.json`.
- When adding/renaming components, update `AGENTS.md`, `README.md`, and `hooks/session-start.sh` (the available-commands list).

## Looking up openEHR specification content

When authoring or editing guides, prompts, BMM JSON, terminology data, AQL grammar notes, or any artefact that must stay aligned with the upstream openEHR standards, **do not guess or rely on training memory**. Retrieve from `specifications.openehr.org`, preferring the cheapest representation (see the MCP server's `guide_get(category="howto", name="spec-lookup")`):

1. **Site index** — `https://specifications.openehr.org/llms.txt` enumerates every release, document, and JSON endpoint.
2. **Markdown twin** — every `*.html` spec page has a `.md` counterpart at the same path. Prefer it for prose. **Caveat:** the Markdown twin omits per-class attribute/function/invariant tables.
3. **Class detail** — for per-class tables, use the MCP `type_specification_get` tool (BMM-backed) or fall through to the HTML page.
4. **Structured APIs** — `/api/components.json`, `/api/classes.json`, `/api/releases.json`.
5. **Development branch, not latest** — track `releases/XX/development/`; use a fixed release tag only when explicitly required.

## Conventions for this repo (the dev plugin itself)

### Authoring skills & agents here
Because this plugin's whole job is authoring tooling, its own components must be exemplary. Full conventions live in [`docs/skill-authoring.md`](docs/skill-authoring.md); the essentials:
- **Scope every skill to the maintainer context.** Use the lean three-part `description` pattern (≈50–75 words): a *what + scope* sentence anchored to the target repo, 3–5 representative *triggers*, and a short *anti-trigger* ("Not for …") routing end-user openEHR work (modelling, AQL, CKM) to the user-facing `openehr-assistant` plugin. An end user must never trip a dev skill — name the strongest signal (workspace is the specific repo + the target file tree).
- **Defer to the target repo's `AGENTS.md`.** Skills summarise and operationalise those conventions; they never restate them as the source of truth.
- **Skills-first, lean, imperative.** Add user-invocable workflows as `skills/<name>/SKILL.md` (no `commands/`). Keep bodies lean (≈1,000 words), use imperative voice, and explain *why* a step matters rather than relying on bare `MUST`/`NEVER`.

### CHANGELOG style
- Entries under `## [Unreleased]` while in flight, folded into `## [X.Y.Z] - YYYY-MM-DD` at release.
- Keep a Changelog groups in order: **Added**, **Changed**, **Deprecated**, **Removed**, **Fixed**, **Security**. Omit empty groups.
- One line per bullet, leading with the subsystem (`Skills:`, `Agent:`, `Hooks:`). Backtick file/skill/tool/URI names. No rationale or PR links — that belongs in commit messages.

### Commit messages
- [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/), e.g. `feat(skills): add example-authoring skill`, `fix(hooks): correct repo detection`.
- Scopes: `skills`, `agents`, `hooks`, `rules`, `docs`, `meta`.

### Versioning
- Plugin version (and, for consistency, description and author) must stay in sync across **both** `.claude-plugin/plugin.json` and `.cursor-plugin/plugin.json`. Follow Semantic Versioning; update both manifests and `CHANGELOG.md` when releasing.

### Documentation sync
When adding or renaming components, update: **AGENTS.md** (component tables), **README.md** (tables), and **hooks/session-start.sh** (the available-skills list).

### Branching
- Feature branches and pull requests from `main`. Standard PR validation runs on every push.
