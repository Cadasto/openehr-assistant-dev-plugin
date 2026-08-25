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
6. **Update the marketplace entry** — the release is not live until this lands. See below.

## Marketplace

This plugin is listed in the separate [Cadasto/plugin-marketplace](https://github.com/Cadasto/plugin-marketplace) repo as `openehr-assistant-dev@cadasto`. The catalog **pins every entry to a release tag**, so tagging and pushing a release here does not ship it — users see nothing until the marketplace entry moves.

After step 5, update the entry in `Cadasto/plugin-marketplace`:

1. Bump that entry's `version` **and** `source.ref` to the new `vX.Y.Z` together (validation there rejects a mismatch).
2. Bump the catalog's own `metadata.version` — a plugin minor/major is a catalog **minor**, a plugin patch is a catalog **patch**.
3. Add a `CHANGELOG.md` line and run `python3 scripts/validate.py --fix`.

See the catalog's [docs/versioning.md](https://github.com/Cadasto/plugin-marketplace/blob/main/docs/versioning.md).

The catalog copies `description`, `version`, and `keywords` verbatim from `.claude-plugin/plugin.json`, so update the entry whenever any of those change — not only on a release.

> The `release-workflow` skill in this plugin covers the *same* mechanics for all three openEHR Assistant repos (mcp, plugin, and this one). This doc is the human-facing quick reference for releasing this repo specifically.
