---
name: guide-prompt-authoring
description: >
  Authors openEHR Assistant implementation guides (`resources/guides/`) and MCP prompts
  (`resources/prompts/` + `src/Prompts/`) in the openehr-assistant-mcp repository. This skill should be
  used when a contributor asks to "create/add/write a guide", "create/add/write an MCP prompt", or
  "author guide/prompt content"; strongest signal is that the workspace is the MCP server repo.
  Not for end-user openEHR work — browsing a guide or asking a modelling question belongs to the
  user-facing `openehr-assistant` plugin.
argument-hint: "<type: guide|prompt> <category/name or prompt-name> [topic description]"
allowed-tools:
  - Read
  - Glob
  - Grep
  - Write
  - Edit
  - Bash
  - mcp__openehr-assistant__guide_search
  - mcp__openehr-assistant__guide_get
  - mcp__openehr-assistant__type_specification_get
  - mcp__openehr-assistant__terminology_resolve
---

# Guide & Prompt Authoring

Create new implementation guides (`resources/guides/`) and MCP prompt files (`resources/prompts/` + `src/Prompts/`) for the **openehr-assistant-mcp** repository.

**Target repo.** This skill operates on the MCP server repo. Read that repo's `AGENTS.md` first — it is authoritative. This skill operationalises its conventions; it does not replace them.

## Conflict Resolution

When conventions conflict, apply this priority (highest first):
1. openEHR specification and formal grammar
2. Existing guide style (see `resources/guides/README.md`)
3. Prompt policy split (global policy vs task-specific constraints)
4. Consistency with sibling files in the same category
5. Convenience

## Step 1: Preparation (MANDATORY)

### 1a. Identify Scope

- **Guide** — normative reference content in `resources/guides/{category}/{name}.md`
- **Prompt** — task-specific MCP prompt in `resources/prompts/{name}.md` + PHP class in `src/Prompts/{Name}.php`

### 1b. Check openEHR Specifications

Verify the topic against authoritative sources before writing — **do not guess or rely on training memory**:
- Load existing guides to understand coverage: `guide_search("<topic>")`, `guide_get("<category>/<name>")`
- Check RM/AM type definitions for data-type/structure topics: `type_specification_get("<type_name>")`
- Verify coded content: `terminology_resolve("<code or term>")`
- Cross-reference `specifications.openehr.org` (llms.txt → `.md` twin → HTML/BMM for class tables), tracking the `development` branch.

### 1c. Check for Duplicates

```
guide_search("<topic>")
Glob: resources/guides/**/*.md      Glob: resources/prompts/*.md
Grep: "<key concept>" in resources/guides/
```
If an existing guide/prompt covers the topic, prefer editing it over creating a new file.

### 1d. Identify the Category

For **guides**, place the file in the correct category directory:

| Category | Directory | Content Focus |
|----------|-----------|---------------|
| Archetypes | `resources/guides/archetypes/` | Archetype design, ADL syntax, constraints, terminology |
| Templates | `resources/guides/templates/` | Template design, OET/OPT syntax, narrowing |
| AQL | `resources/guides/aql/` | Query language, syntax, patterns |
| Simplified Formats | `resources/guides/simplified_formats/` | Flat/Structured JSON serialization |
| Specifications | `resources/guides/specs/` | openEHR spec digests (250–900 words); `<component>-<doc>.md` (e.g. `rm-ehr.md`, `am2-ADL2.md`); track `development` |
| How-Tos | `resources/guides/howto/` | Toolchain how-tos (e.g. `spec-lookup.md`) |

The legacy `rm/` category is retired (migrated to `specs/`). **Spec digests** in `specs/` follow a validated schema — inspect a sibling digest (e.g. `specs/rm-ehr.md`) and the category README/validator before authoring. Guide-authoring scaffolding lives under `src/templates/` — start there.

For **prompts**, identify the action pattern:

| Pattern | Naming | Example |
|---------|--------|---------|
| Design or review | `design_or_review_{subject}` | `design_or_review_archetype.md` |
| Explain | `explain_{subject}` | `explain_template.md` |
| Explore / browse | `{subject}_explorer` | `guide_explorer.md` |
| Fix / transform | `fix_{subject}` | `fix_adl_syntax.md` |
| Translate | `translate_{subject}` | `translate_archetype_language.md` |

## Step 2: Author a Guide

### 2a. Header Block
Every guide starts with a metadata header **before** the `---` separator:

```markdown
# Title

**Scope:** What this guide covers — one or two sentences.
**Related:** openehr://guides/{category}/{name}, openehr://guides/{category}/{other}
**Keywords:** comma, separated, discovery, terms

---
```
**Scope** (or **Purpose**) is required; **Related** and **Keywords** are recommended.

### 2b. Section Heading Style

| Document Type | Heading Style |
|---------------|---------------|
| Long normative (rules, standards) | Lettered: A1, A2, B1… |
| Short reference / cheat sheet | Numeric: 1, 2, 3… |
| Principles / overview | Unnumbered short titles |

### 2c. Content Principles
- **Concise and scannable** — consumed by AI agents; avoid verbose prose.
- **Specification-aligned** — wording aligned with authoritative specs.
- **Self-contained** yet cross-referencing related guides.
- **Examples over explanation** — use code blocks.
- **No duplicate content** — cross-reference instead of repeating.

### 2d. Code Blocks and Checklists
- ` ```text ` for prose examples; language tags (`adl`, `json`, `sql`) where they add value.
- `☑` for conformance checklists embedded in guides; `- [ ]` for interactive checklist guides.

### 2e. Standard Guide Types
`principles.md`, `rules.md`, `{format}-syntax.md`, `idioms-cheatsheet.md`, `anti-patterns.md`, `checklist.md`, `terminology.md`, `structural-constraints.md`.

## Step 3: Author a Prompt

### 3a. Prompt Markdown File
Create `resources/prompts/{name}.md`:

```markdown
## Role: user

{Task description and instructions for the assistant.}

Ground all decisions on:
- `openehr://guides/{category}/{guide1}`

### Workflow
1. {Step 1}

### Required Deliverables
1. {Deliverable 1}

### Conflict Resolution
{Priority hierarchy for resolving ambiguity.}

### Template Variables
- Task type: {{task_type}}
```

Rules: use `## Role: user`; reference guides by `openehr://guides/...` URI; include `{{var}}` template variables; keep task-specific (global policy lives in `resources/server-instructions.md`, **not** here); define required deliverables.

### 3b. Prompt Policy Split
- **`resources/server-instructions.md`** (or `resources/prompts/shared/policy.md`) — global, always-applicable policy (tool discipline, scope control, spec compliance, output standards).
- **`resources/prompts/{name}.md`** — task-specific constraints, required output structure, domain rules, guide references.

Never duplicate shared policy in individual prompt files.

### 3c. PHP Prompt Class
Create `src/Prompts/{PascalName}.php`:

```php
<?php

declare(strict_types=1);

namespace Cadasto\OpenEHR\MCP\Assistant\Prompts;

use Mcp\Attribute\McpPrompt;
use Mcp\Attribute\McpPromptArgument;

#[McpPrompt(name: '{name}', description: '{What this prompt does}')]
class {PascalName} extends AbstractPrompt
{
    public function __invoke(
        #[McpPromptArgument(name: '{arg_name}', description: '{Argument description}', required: true)]
        string $argName,
    ): array {
        return $this->loadPromptMessages('{snake_name}', ['arg_name' => $argName]);
    }
}
```
PascalCase class matches the snake_case markdown filename; extends `AbstractPrompt`; uses `#[McpPrompt]`/`#[McpPromptArgument]`; arguments match the markdown's template variables.

## Step 4: Quality Review

### 4a. Guide Checklist
- [ ] Header block includes Scope/Purpose; Related URIs; Keywords
- [ ] Heading style fits the document type
- [ ] Spec-aligned (verified against authoritative sources)
- [ ] No duplicated content — cross-references instead
- [ ] Appropriate code-block language tags; concise/scannable
- [ ] Correct category directory; filename follows conventions

### 4b. Prompt Checklist
- [ ] `## Role: user` header; references guides by URI; `{{var}}` variables; required deliverables
- [ ] No duplicated shared policy
- [ ] PHP class extends `AbstractPrompt`, uses `loadPromptMessages()`, correct attributes
- [ ] PascalCase class matches snake_case filename; arguments match template variables

### 4c. Documentation Sync & Tests
After creating files, in the MCP repo: update `AGENTS.md` (new prompt / resource-structure changes) and `README.md` (public API / capabilities); add a PHPUnit test for new prompt classes in `tests/`. Run tests via the Docker dev container (see the MCP repo `AGENTS.md`) — never on the host.

## Output
- Guides: `resources/guides/{category}/{name}.md`
- Prompts: `resources/prompts/{name}.md` + `src/Prompts/{PascalName}.php`

Use the Write tool for new files, Edit for existing ones.
