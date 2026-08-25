---
name: release-workflow
description: >
  Releases the openEHR Assistant projects: SemVer bump, Keep-a-Changelog curation, dual-host manifest
  sync, and mcp<->plugin compatibility alignment. This skill should be used when a maintainer asks to
  "cut a release", "bump the version", "prepare a release", "update the changelog", or "bump
  openehr-assistant-mcp compatibility" for the openehr-assistant-mcp server, the openehr-assistant
  plugin, or this dev plugin. Not for releasing unrelated projects or general versioning questions.
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

## Step 6: Repin the marketplace entry (both plugin repos)

Applies to `openehr-assistant-plugin` and `openehr-assistant-dev-plugin`, not the MCP server.

Both are listed in [`Cadasto/plugin-marketplace`](https://github.com/Cadasto/plugin-marketplace), whose catalog **pins each entry to a release tag**. Pushing the tag does not ship the release — users see nothing until the catalog entry moves. Treat the release as incomplete until it does.

In `.claude-plugin/marketplace.json` of that repo:

1. Bump the entry's `version` **and** `source.ref` to the new `vX.Y.Z` together — its validator rejects a mismatch.
2. Bump the catalog's own `metadata.version`: a plugin minor/major is a catalog **minor**, a plugin patch a catalog **patch**.
3. Add a `CHANGELOG.md` line, then run `python3 scripts/validate.py --fix` (regenerates the Cursor twin) and `claude plugin validate .`.

The catalog copies `description`, `version`, and `keywords` verbatim from `.claude-plugin/plugin.json`, so a wording change to any of those needs the entry updated too — even without a release.

## Checklist
- [ ] SemVer bump correct for the change set
- [ ] CHANGELOG: `[Unreleased]` folded into dated section; groups ordered; every commit represented once
- [ ] Version bumped in **all** locations (constants.php OR both plugin manifests)
- [ ] Plugin manifests agree on version/description/author
- [ ] Compatibility pointer + `allowed-tools` + guide URIs aligned (if MCP surface changed)
- [ ] Bundled archetype corpus synced + `Synced from:` updated (if archetypes changed)
- [ ] Docs synced (AGENTS.md, README.md, session-start.sh)
- [ ] Tests/lint green (MCP, in Docker); plugins smoke-tested
- [ ] Marketplace entry repinned in `Cadasto/plugin-marketplace` (plugin repos only) — `version` + `source.ref` bumped together, catalog `metadata.version` and CHANGELOG updated
