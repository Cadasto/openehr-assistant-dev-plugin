---
name: example-authoring
description: >
  Authors curated worked examples in the openehr-assistant-mcp repo's `resources/examples/` corpus
  (the `openehr://examples/{aql|flat|structured|archetypes}` namespace). This skill should be used when
  a contributor asks to "add a curated example", "add a reference AQL/FLAT/STRUCTURED example to the
  examples corpus", or "author an examples entry"; strongest signal is editing files under
  `resources/examples/`. Not for an end user wanting an AQL query or payload for their own clinical work
  — that is the user-facing `openehr-assistant` plugin (its aql-query / composition-builder skills).
argument-hint: "<kind: aql|flat|structured|archetypes> <name> [pattern/topic]"
allowed-tools:
  - Read
  - Glob
  - Grep
  - Write
  - Edit
  - mcp__openehr-assistant__examples_search
  - mcp__openehr-assistant__examples_get
  - mcp__openehr-assistant__guide_get
  - mcp__openehr-assistant__type_specification_get
  - mcp__openehr-assistant__ckm_archetype_get
---

# Curated Example Authoring

Author curated worked examples in the `openehr://examples/{kind}/{name}` namespace of the **openehr-assistant-mcp** repository. Examples are gold-standard patterns the model retrieves via `examples_search` / `examples_get`.

**Target repo.** Read the MCP repo's `AGENTS.md` first. Examples live under `resources/examples/{kind}/` and are auto-discovered by `ExamplesService` (`EXAMPLES_DIR = resources/examples`); no manual registration is needed.

## The four kinds

| Kind | Directory | File type | Served as |
|------|-----------|-----------|-----------|
| `aql` | `resources/examples/aql/` | Markdown (header + fenced ```aql```) | text |
| `flat` | `resources/examples/flat/` | Markdown (header + fenced ```json```) | text |
| `structured` | `resources/examples/structured/` | Markdown (header + fenced ```json```) | text |
| `archetypes` | `resources/examples/archetypes/` | native `.adl` | `text/plain` |

`aql` / `flat` / `structured` are **Markdown with a metadata header**. `archetypes` are **CKM-published native `.adl`** files (one per RM entry type: OBSERVATION, EVALUATION, INSTRUCTION, ACTION, CLUSTER, COMPOSITION, ADMIN_ENTRY).

## Step 1: Preparation (MANDATORY)

1. **Avoid duplicates** — `examples_search("<topic>", kind="<kind>")` and `Glob: resources/examples/{kind}/*`. Prefer editing an existing example over adding a near-duplicate.
2. **Pick a clear pattern** — each example demonstrates ONE named pattern (e.g. "half-open time-window filter", "FLAT `|magnitude`/`|unit` pipe suffixes"). If it has no crisp pattern, it does not belong.
3. **Ground in the spec/guides** — do not guess paths or RM detail. Use `guide_get(...)`, `type_specification_get("<type>")`, and for archetype examples `ckm_archetype_get(...)`. Track the `development` branch.
4. **Name** — `snake_case` for `aql/flat/structured` (the URI `{name}`); for `archetypes` keep the canonical archetype id filename (e.g. `openEHR-EHR-OBSERVATION.blood_pressure.v2.adl`).

## Step 2: Metadata header (aql / flat / structured)

Every Markdown example starts with a `#` title, a metadata block, then a `---` separator, then a single fenced code block, then optional `## Notes`. Match sibling files exactly.

**AQL example header:**
```markdown
# <Title> — AQL Example

**Pattern:** <short pattern name>
**Demonstrates:** <comma-separated techniques>
**Inputs:** `$ehrId`, `$from` (ISO 8601), `$to` (ISO 8601)
**Related:** `openehr://guides/specs/query-AQL`, `openehr://guides/aql/principles`

---

​```aql
SELECT … FROM EHR e CONTAINS COMPOSITION c …
​```

## Notes
- <why this pattern is correct / boundary semantics / pitfalls>
```

**FLAT / STRUCTURED example header:**
```markdown
# <Title> (FLAT JSON) — Example Payload

**Pattern:** <short pattern name>
**Demonstrates:** `ctx/` context fields, flat-path keys, `|magnitude`/`|unit` pipe suffixes, `:n` instance indices
**MIME type:** `application/openehr.wt.flat+json`
**Paired example:** `openehr://examples/structured/<name>` (same composition, STRUCTURED form)
**Template:** assumes a template `…` that includes `openEHR-EHR-OBSERVATION.<concept>.vN`
**Related:** `openehr://guides/specs/its-rest-simplified_formats`, `openehr://guides/simplified_formats/principles`

---

​```json
{ "ctx/language": "en", … }
​```
```

Header conventions:
- **Pattern** and **Demonstrates** are required; backtick field identifiers, suffixes, and URIs.
- **FLAT and STRUCTURED come in pairs** — when adding one, add or reference its counterpart for the *same* composition via the `Paired example:` line.
- **Related** points to canonical `openehr://guides/...` URIs.

## Step 3: Archetype examples (.adl)

- Use a **CKM-published** archetype as-is; do not invent or hand-edit clinical content.
- Convention: **English-only** — strip non-English translations from `term_definitions` / `term_bindings` to keep the corpus lean (these files double as the offline corpus bundled into the user-facing plugin's `clinical-modeler` agent).
- Keep one archetype per RM entry type; replace rather than accumulate versions.

## Step 4: Verify & document

- Confirm the file parses/serialises (AQL is syntactically valid; FLAT/STRUCTURED JSON is valid JSON; `.adl` is valid ADL).
- `examples_search` should surface the new entry by its title/pattern keywords once discovered.
- Update `AGENTS.md` / `README.md` example inventories in the MCP repo if counts or kinds change.
- If archetype examples changed, note the sync obligation for the user-facing plugin's bundled corpus (see the `release-workflow` skill and the plugin's `CONTRIBUTING.md`).

## Checklist
- [ ] No duplicate; demonstrates one crisp, named pattern
- [ ] Correct kind directory and naming (`snake_case` or canonical archetype id)
- [ ] Metadata header complete (Pattern, Demonstrates, Related; MIME + Paired for flat/structured)
- [ ] Spec/guide-grounded; paths and RM detail verified (not guessed)
- [ ] Single fenced code block of the correct language; valid content
- [ ] FLAT/STRUCTURED pair kept consistent
- [ ] Inventories/counts updated where referenced
