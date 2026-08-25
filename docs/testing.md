# Testing and validation

This is a pure-content repository — JSON manifests + markdown skills/agents + a hook script, with no build step and no package manager. Testing means validating structure, then installing locally and exercising the skills against the target repos.

## Validation

- **Manifest / component validation** — `./scripts/validate.sh` (also run by CI on every PR): checks both `plugin.json` manifests, dual-host parity (name/version/description/author agree), declared component paths, hook-config JSON, and SKILL.md / agent frontmatter (including `name` == directory/filename). The wrapper runs `scripts/validate.py`; if Python 3 isn't installed it prints a warning and skips (exit 0) rather than failing — install `python3` for the full local check, or rely on `claude plugin validate .` and CI. CI pins Python so the deep check always runs there.
- **Official validator** — `claude plugin validate .`: checks the manifest and component structure.
- **Structural review** — run the `plugin-dev:plugin-validator` agent after creating or modifying components.
- **Skill quality review** — run the `plugin-dev:skill-reviewer` agent: description-triggering quality, progressive disclosure, content structure.
- **Token cost** — `claude plugin details openehr-assistant-dev` shows the inventory and projected token cost; keep skill metadata lean.

## Local triggering tests

Install from your working copy (see [install.md](install.md)), then open a checkout of a target repo and confirm behaviour:

- Open **openehr-assistant-mcp** → the `SessionStart` hook should announce the MCP-server context and the authoring skills should trigger on their documented phrases (for example "add an MCP tool", "create a guide").
- Open **openehr-assistant-plugin** → the hook should announce the plugin context.
- **Anti-trigger check (important):** in an ordinary end-user openEHR session (for example "write me an AQL query for blood pressure"), the dev skills must **not** trigger — that work belongs to the user-facing plugin. See each skill's `description` for its anti-trigger boundary and [skill-authoring.md](skill-authoring.md).

After editing content, reinstall (or restart the session) to pick up changes.

## Releasing

See [versioning.md](versioning.md) for the semver policy and release steps.
