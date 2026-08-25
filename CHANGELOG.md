# Changelog

All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog, and this project adheres to Semantic Versioning.

- Keep a Changelog: [https://keepachangelog.com/en/1.1.0/](https://keepachangelog.com/en/1.1.0/)
- Semantic Versioning: [https://semver.org/spec/v2.0.0.html](https://semver.org/spec/v2.0.0.html)

## [0.3.0] - 2026-08-25

Corrects an install command that never existed, propagated into the `release-workflow` skill and the `repo-conventions-scout` agent and from there into the repos this plugin documents. `release-workflow` also gains the marketplace repin step, without which a tagged release reaches nobody.

### Changed
- Docs: `README.md` — the version badge reads the latest GitHub release instead of a hardcoded `0.2.0`, so it cannot fall behind a tag. Verified it renders `v0.2.0` today.
- Docs: `docs/versioning.md` — release steps now include **cutting the GitHub release** (step 6), which the repo has always done but never documented; the marketplace repin follows as step 7. Matches the org rule in the catalog's own versioning doc: every tag carries a release titled exactly the tag name, with the CHANGELOG section as the body.
- Docs: `docs/install.md` — the marketplace command uses the canonical `Cadasto` casing, matching `README.md`; the two disagreed in the same command.
- Docs: sentence-case H1s in `docs/testing.md`, `docs/versioning.md`, `docs/skill-authoring.md`; "for example" over "e.g."; `docs/testing.md` opens with its subject rather than "There is".
- Skills: `release-workflow` — new Step 6 and checklist item: repin the entry in `Cadasto/plugin-marketplace` for both plugin repos. The catalog pins each entry to a release tag, so pushing the tag no longer ships the release.
- Docs: `docs/versioning.md` — the marketplace no longer tracks `main`; added as a release step.

### Fixed
- Docs: `README.md` — the table of contents omitted the **Documentation** section, so the four `docs/` references were unreachable from the contents list.
- Docs: `claude plugin add` is not a Claude Code command. `README.md`, `docs/install.md`, `CONTRIBUTING.md`, and `AGENTS.md` load a local working copy with `claude --plugin-dir <path>`, which applies to that session only; the README's Claude Code install now shows the marketplace flow.
- Skills, Agents: `release-workflow` and `repo-conventions-scout` carried the same non-existent command and propagated it into the repos they document.

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
