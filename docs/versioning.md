# Versioning and Releases

This plugin is versioned with [semver](https://semver.org), adapted to skill/agent content:

| Bump | When |
|------|------|
| **Major** | A skill/agent is removed or renamed, or its behaviour/scope changes incompatibly |
| **Minor** | A new skill/agent is added, or an existing one's coverage meaningfully expands |
| **Patch** | Typos, clarifications, reference fixes — no behaviour change |

## Release steps

1. Bump `version` in **both** manifests (they must agree): `.claude-plugin/plugin.json` and `.cursor-plugin/plugin.json`. Keep `description` and `author` identical across both.
2. Run `./scripts/validate.sh` (checks dual-host parity; warns and skips if Python is absent) and `claude plugin validate .`.
3. Fold the accumulated `## [Unreleased]` notes into a dated `## [X.Y.Z]` section in [CHANGELOG.md](../CHANGELOG.md) (Keep a Changelog format — see [AGENTS.md](../AGENTS.md#changelog-style)).
4. Commit (`chore(release): vX.Y.Z`) and tag: `git tag -a vX.Y.Z -m "openEHR Assistant Dev Plugin vX.Y.Z"`.
5. Push commits and the tag: `git push origin main --follow-tags`.

## Marketplace

This plugin is listed in the separate [cadasto/plugin-marketplace](https://github.com/cadasto/plugin-marketplace) repo via a GitHub `source`, so the marketplace always tracks `main` — no version pin to bump there. Only update the marketplace when the plugin's `name`, `description`, or `repo` changes.

> The `release-workflow` skill in this plugin covers the *same* mechanics for all three openEHR Assistant repos (mcp, plugin, and this one). This doc is the human-facing quick reference for releasing this repo specifically.
