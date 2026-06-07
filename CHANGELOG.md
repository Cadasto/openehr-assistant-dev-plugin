# Changelog

All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog, and this project adheres to Semantic Versioning.

- Keep a Changelog: [https://keepachangelog.com/en/1.1.0/](https://keepachangelog.com/en/1.1.0/)
- Semantic Versioning: [https://semver.org/spec/v2.0.0.html](https://semver.org/spec/v2.0.0.html)

## [Unreleased]

### Added

- `scripts/validate.py` + `scripts/validate.sh` (graceful wrapper — warns and skips if Python is absent) + `.github/workflows/validate.yml` (pins Python, strict) — validation of manifests, dual-host parity, and frontmatter (adapted from `openehr/ai-plugins`).
- `.claude/` — `settings.json` (enables maintainer plugins) and `CLAUDE.md` delegating to `AGENTS.md`.
- `.github/` — issue templates (`proposal`, `skill-bug`) and `PULL_REQUEST_TEMPLATE.md`.
- `docs/` — `install`, `testing`, `versioning`, and `skill-authoring` references.
- `CODE_OF_CONDUCT.md` and `SECURITY.md` (content-integrity / supply-chain threat model and private reporting).

### Changed

- Skills: tightened the four skill `description`s to the lean three-part triggering pattern (scope anchor + triggers + anti-trigger).

## [0.1.0] - 2026-06-07

### Added

- Initial maintainer plugin for the openEHR Assistant ecosystem (Claude Code + Cursor).
- Skills: `guide-prompt-authoring`, `mcp-tool-authoring`, `example-authoring`, `release-workflow`.
- Agent: `repo-conventions-scout` — detects the target repo and surfaces applicable conventions.
- Hooks: `SessionStart` repo-detection + Docker-only reminder (`hooks.json`, `cursor-hooks.json`, `session-start.sh`).
- Cursor rule `rules/dev-context.mdc` and `AGENTS.md` as the canonical AI guideline source.
