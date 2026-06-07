# Changelog

All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog, and this project adheres to Semantic Versioning.

- Keep a Changelog: [https://keepachangelog.com/en/1.1.0/](https://keepachangelog.com/en/1.1.0/)
- Semantic Versioning: [https://semver.org/spec/v2.0.0.html](https://semver.org/spec/v2.0.0.html)

## [Unreleased]

## [0.1.0] - 2026-06-07

### Added

- Initial maintainer plugin for the openEHR Assistant ecosystem (Claude Code + Cursor).
- Skills: `guide-prompt-authoring`, `mcp-tool-authoring`, `example-authoring`, `release-workflow`.
- Agent: `repo-conventions-scout` — detects the target repo and surfaces applicable conventions.
- Hooks: `SessionStart` repo-detection + Docker-only reminder (`hooks.json`, `cursor-hooks.json`, `session-start.sh`).
- Cursor rule `rules/dev-context.mdc` and `AGENTS.md` as the canonical AI guideline source.
