# Skill and Agent Authoring Conventions

This plugin's whole job is authoring tooling, so its own skills and agents must be exemplary. This is the detailed companion to the "Authoring skills & agents here" section of [AGENTS.md](../AGENTS.md).

## Naming

- **Plugin name**: `openehr-assistant-dev` — the `openehr-assistant-` prefix groups it with the ecosystem; the `-dev` suffix marks it as maintainer tooling. Claude Code plugin names live in a flat global namespace, so a descriptive prefix disambiguates it.
- **Skill / agent names**: terse activity nouns (e.g. `mcp-tool-authoring`, `example-authoring`, `release-workflow`, `repo-conventions-scout`). Skills are namespaced as `<plugin>:<skill>` (`openehr-assistant-dev:release-workflow`), so don't repeat the plugin's words in a skill name.
- **Do not duplicate end-user tooling.** Clinical modelling, AQL, and CKM workflows belong to the user-facing [openehr-assistant](https://github.com/cadasto/openehr-assistant-plugin) plugin. Skills here cover *building* the tooling, not *using* openEHR.

## Layout

- `skills/<name>/SKILL.md` — one subdirectory per skill, YAML frontmatter + markdown body. Optional `references/` subdirectory for bulky supplementary content.
- `agents/<name>.md` — one file per agent, YAML frontmatter + system prompt.
- This plugin is **skills-first**: there is no `commands/` directory. Add user-invocable workflows as skills.
- Keep both manifests (`.claude-plugin/plugin.json`, `.cursor-plugin/plugin.json`) in sync — `scripts/validate.py` enforces this.

## The `description` field (the trigger)

The `description` is always-on trigger metadata — it sits in context every session, so keep it **lean (~50–75 words)**. Follow this three-part pattern, in the third person:

1. **What + scope** — one sentence: what the skill does, anchored to the target repo (e.g. "in the openehr-assistant-mcp repository"). This anchor *is* the scope limit.
2. **Triggers** — "This skill should be used when a contributor asks to …" with 3–5 *representative* (not exhaustive) actions. More phrases past that add length without improving triggering.
3. **Anti-triggers** — a short "Not for …" / "Do NOT trigger …" that routes overlapping end-user cases to the owning plugin (e.g. "an end user wanting an AQL query → the user-facing `openehr-assistant` plugin").

The anti-trigger is the most important part for this plugin: every dev skill shares vocabulary with end-user openEHR work ("add an example", "write a guide"), so each must explicitly disclaim that context. Name the **strongest positive signal** too — usually "the workspace is the specific repo + the target file tree".

## Body

- Imperative voice; explain *why* a step matters rather than relying on bare `MUST`/`NEVER`.
- Keep bodies focused (~1,000 words). Push bulky reference material to `references/`.
- **Defer to the target repo's own `AGENTS.md`** — it is authoritative. Skills summarise and operationalise its conventions; they never restate them as the source of truth.
- Stay factual and grounded — do not invent identifiers, paths, or conventions. For openEHR spec detail, retrieve from `specifications.openehr.org` (see [AGENTS.md](../AGENTS.md#looking-up-openehr-specification-content)).

## Before committing

Run `./scripts/validate.sh` and `claude plugin validate .`, then test triggering and anti-triggering locally — see [testing.md](testing.md).
