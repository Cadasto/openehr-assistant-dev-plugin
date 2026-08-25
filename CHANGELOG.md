# Changelog

All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog, and this project adheres to Semantic Versioning.

- Keep a Changelog: [https://keepachangelog.com/en/1.1.0/](https://keepachangelog.com/en/1.1.0/)
- Semantic Versioning: [https://semver.org/spec/v2.0.0.html](https://semver.org/spec/v2.0.0.html)

## [Unreleased]

### Changed
- Skills: `release-workflow` — new Step 6 and checklist item: repin the entry in `Cadasto/plugin-marketplace` for both plugin repos. The catalog pins each entry to a release tag, so pushing the tag no longer ships the release.
- Docs: `docs/versioning.md` — the marketplace no longer tracks `main`; added as release step 6.

## [0.2.0] - 2026-06-07

### Added

- Validation: `scripts/validate.py` (manifests, dual-host parity, frontmatter), `scripts/validate.sh` (graceful wrapper — warns and skips if Python is absent), and `.github/workflows/validate.yml` (pins Python, strict in CI). Adapted from `openehr/ai-plugins`.
- `.claude/`: `settings.json` (enables maintainer plugins) and `CLAUDE.md` delegating to `AGENTS.md`.
- `.github/`: issue templates (`proposal`, `skill-bug`) and `PULL_REQUEST_TEMPLATE.md`.
- `docs/`: `install`, `testing`, `versioning`, and `skill-authoring` references.
- `CODE_OF_CONDUCT.md` and `SECURITY.md` (content-integrity / supply-chain threat model and private reporting).
- AGENTS.md: "Testing & validating this plugin", "Gotchas", and "Authoring skills & agents here" sections.

### Changed

- Skills: scoped all four `description`s to the maintainer/dev context and tightened them to the lean three-part triggering pattern (scope anchor + triggers + anti-trigger), ~50–75 words each.
- Docs: reduced gratuitous "PHP MCP server" framing across `AGENTS.md`, `README.md`, and hooks (kept genuine PHP code/test/stack references).

## [0.1.0] - 2026-06-07

### Added

- Initial maintainer plugin for the openEHR Assistant ecosystem (Claude Code + Cursor).
- Skills: `guide-prompt-authoring`, `mcp-tool-authoring`, `example-authoring`, `release-workflow`.
- Agent: `repo-conventions-scout` — detects the target repo and surfaces applicable conventions.
- Hooks: `SessionStart` repo-detection + Docker-only reminder (`hooks.json`, `cursor-hooks.json`, `session-start.sh`).
- Cursor rule `rules/dev-context.mdc` and `AGENTS.md` as the canonical AI guideline source.
