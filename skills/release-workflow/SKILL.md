---
name: release-workflow
description: >
  This skill should be used when the user asks to "cut a release", "bump the version", "prepare a
  release", "update the changelog", "sync the plugin manifests", or "bump openehr-assistant-mcp
  compatibility". Covers Semantic Versioning, Keep-a-Changelog curation, plugin manifest sync
  (.claude-plugin / .cursor-plugin), and mcp <-> plugin compatibility alignment for the openEHR
  Assistant MCP server and plugin.
argument-hint: "<repo: mcp|plugin> <version X.Y.Z> [--align-mcp X.Y.Z]"
allowed-tools:
  - Read
  - Glob
  - Grep
  - Write
  - Edit
  - Bash
---

# Release Workflow

Prepare releases for the two openEHR Assistant repos and keep them version-aligned. This skill covers **versioning, CHANGELOG curation, manifest sync, and cross-repo compatibility**. It does not push or tag without explicit instruction.

**Target repo.** Read the target repo's `AGENTS.md` (and `CONTRIBUTING.md` for the plugin) first — they are authoritative for version locations and CHANGELOG style.

## Step 0: Identify the repo and version locations

| Repo | Version source of truth | Also reflect in |
|------|-------------------------|------------------|
| `openehr-assistant-mcp` | `src/constants.php` (`APP_VERSION`) | `CHANGELOG.md`, README badges |
| `openehr-assistant-plugin` | **both** `.claude-plugin/plugin.json` **and** `.cursor-plugin/plugin.json` | `CHANGELOG.md`, README version + compatibility badges |
| `openehr-assistant-dev-plugin` (this) | both `.claude-plugin/plugin.json` and `.cursor-plugin/plugin.json` | `CHANGELOG.md`, README badge |

Apply **SemVer**: breaking → major, new features → minor, fixes → patch.

## Step 1: Curate the CHANGELOG (Keep a Changelog)

- Fold accumulated `## [Unreleased]` bullets into a new `## [X.Y.Z] - YYYY-MM-DD` section. Use today's date.
- Groups in order: **Added**, **Changed**, **Deprecated**, **Removed**, **Fixed**, **Security**. Omit empty groups.
- One line per bullet, leading with the subsystem (`Tools:`, `Guides:`, `Skills:`, `Commands:`, `Guide URIs:`). Backtick file/tool/URI/frontmatter-key names. No rationale or PR links.
- **Completeness check:** run `git log <last-tag>..HEAD --oneline` and ensure every change is represented exactly once across the groups.

```bash
git describe --tags --abbrev=0          # last release tag
git log "$(git describe --tags --abbrev=0)..HEAD" --oneline
```

## Step 2: Bump the version (atomic, all locations)

**MCP repo:**
- Edit `APP_VERSION` in `src/constants.php`.
- Update README version badge/text and CHANGELOG.

**Plugin repos:**
- Update `version` in **both** `.claude-plugin/plugin.json` and `.cursor-plugin/plugin.json` — they must match. Keep `description` and `author` identical across both too.
- Update README version badge and CHANGELOG.

Verify both plugin manifests agree:
```bash
grep -h '"version"' .claude-plugin/plugin.json .cursor-plugin/plugin.json
```

## Step 3: Cross-repo compatibility alignment

The user-facing **plugin** declares compatibility with a specific **MCP** server version (e.g. "aligned with openehr-assistant-mcp v0.16.0"). When the MCP server's public surface changes, align the plugin **in this order**:

1. **Compatibility strings** — update the pointer in the plugin's `AGENTS.md`, `README.md` (Companion MCP section + badge), and `CHANGELOG.md`.
2. **MCP tool names (`allowed-tools`)** — diff every `mcp__openehr-assistant__*` id in `skills/**`, `commands/**`, `agents/**` against the tools the new MCP version exposes (`src/Tools` registry / MCP README). Add/remove/rename so hosts neither prompt for unknown tools nor block missing ones.
   ```bash
   # in the plugin repo: list referenced tool ids
   grep -rhoE 'mcp__openehr-assistant__[a-z_]+' skills commands agents | sort -u
   # in the mcp repo: list exposed tool names
   grep -rhoE "name:\s*'[a-z_]+'" src/Tools | sort -u
   ```
3. **Guide URIs and categories** — if guide paths/categories changed (`specs/`, `howto/`, retired `rm/`), update `guide_get` / `guide_search` examples in skills and commands.
4. **Bundled archetype corpus** — the plugin bundles 7 gold-standard archetypes in `skills/openehr-assistant/examples/*.adl` for the offline `clinical-modeler` agent, mirroring the MCP's `resources/examples/archetypes/*.adl`. After bumping the pointer: `diff` the two sets, sync changed files (keep the "English-only, translations stripped" convention), and update the `**Synced from:**` line in the plugin's `skills/openehr-assistant/examples/README.md`. Do **not** bundle `aql`/`flat`/`structured` — those are fetched via MCP on demand.

## Step 4: Documentation sync (per repo)

- **MCP**: `AGENTS.md` (conventions/counts), `README.md` (capability tables).
- **Plugin**: `AGENTS.md` + `README.md` component tables, and `hooks/session-start.sh` (the "Available: /command…" list) when commands change.
- **This dev plugin**: `AGENTS.md` + `README.md` component tables, and `hooks/session-start.sh` (available-skills lines).

## Step 5: Verify before tagging

- **MCP** (Docker dev container, never host): `composer test` and `composer check:phpstan` green; optionally `make conformance`.
- **Plugins**: install locally (`claude plugin add .`) and smoke-test a representative skill/command.
- Confirm working tree contains exactly the intended release delta: `git status`, `git diff`.

Only commit/tag/push when the user explicitly asks. Suggested commit: `chore(release): vX.Y.Z`. Suggested tag: `vX.Y.Z` (match the repo's existing tag convention — check `git tag` first).

## Checklist
- [ ] SemVer bump correct for the change set
- [ ] CHANGELOG: `[Unreleased]` folded into dated section; groups ordered; every commit represented once
- [ ] Version bumped in **all** locations (constants.php OR both plugin manifests)
- [ ] Plugin manifests agree on version/description/author
- [ ] Compatibility pointer + `allowed-tools` + guide URIs aligned (if MCP surface changed)
- [ ] Bundled archetype corpus synced + `Synced from:` updated (if archetypes changed)
- [ ] Docs synced (AGENTS.md, README.md, session-start.sh)
- [ ] Tests/lint green (MCP, in Docker); plugins smoke-tested
