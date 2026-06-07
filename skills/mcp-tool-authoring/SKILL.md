---
name: mcp-tool-authoring
description: >
  This skill should be used when the user asks to "add an MCP tool", "create a new tool",
  "add a resource", "add a resource template", "add a completion provider", or "expose a new
  capability" in the openEHR Assistant MCP server. Covers authoring #[McpTool], #[McpResource],
  #[McpResourceTemplate], and CompletionProvider classes in src/ with matching PHPUnit tests,
  run via the Docker dev container.
argument-hint: "<tool|resource|resource-template|completion-provider> <name> [description]"
allowed-tools:
  - Read
  - Glob
  - Grep
  - Write
  - Edit
  - Bash
  - mcp__openehr-assistant__type_specification_get
  - mcp__openehr-assistant__guide_get
---

# MCP Tool, Resource & Completion-Provider Authoring

Author and extend MCP capabilities in the **openehr-assistant-mcp** repository: tools, resources, resource templates, and completion providers — each with matching PHPUnit tests.

**Target repo.** Read the MCP repo's `AGENTS.md` first — it is authoritative for layout, coding standards, and the Docker workflow. This skill operationalises those conventions.

## Critical constraints

- **Docker-only runtime.** Never run `php`/`composer`/`vendor/bin/*` on the host. Use the dev container (Step 4).
- **PSR-12**, PHP 8.4, typed signatures, small methods. Production namespace `Cadasto\OpenEHR\MCP\Assistant\` (`src/`).
- **Attribute-driven discovery.** `public/index.php` calls `setDiscovery(APP_DIR, ['src/Prompts', 'src/Tools', 'src/Resources'], cache: $cache)`. A new class in those directories is auto-registered — **but discovery is cached**; clear the cache after adding/renaming a class (Step 4).
- **Mock external HTTP** (CKM) in tests — never hit live APIs.

## Step 1: Decide the capability type

| Type | Directory | Attribute | Returns |
|------|-----------|-----------|---------|
| Tool | `src/Tools/` | `#[McpTool(name: '…')]` on a public method | scalar/array/`TextContent` |
| Resource (fixed URI) | `src/Resources/` | `#[McpResource(uri: '…')]` | string / content |
| Resource template (parameterised) | `src/Resources/` | `#[McpResourceTemplate(uriTemplate: 'openehr://…/{x}')]` | string / content |
| Completion provider | `src/CompletionProviders/` | implements `Mcp\Capability\Completion\ProviderInterface` | `array<string>` |

Search for an existing capability before adding a new one: `Glob: src/Tools/*.php`, `Grep: "#[McpTool"`.

## Step 2: Author the class

### Tool
Add a method to an existing `*Service` class when it fits, or create a new `final readonly class` with constructor DI (`LoggerInterface`, API clients):

```php
#[McpTool(
    name: 'snake_case_tool_name',
    annotations: new ToolAnnotations(readOnlyHint: true),
    outputSchema: [
        'type' => 'object',
        'properties' => [ 'id' => ['type' => 'string'], 'rubric' => ['type' => 'string'] ],
    ],
)]
public function resolve(string $input, string $groupId = ''): array
{
    $this->logger->debug('called ' . __METHOD__, func_get_args());
    $input = trim($input);
    if ($input === '') {
        throw new ToolCallException('Input cannot be empty.');
    }
    // …
}
```

Conventions:
- Tool `name` is `snake_case`; the **method-level PHPDoc is the tool description** the model sees — write it for an LLM (when to call, workflow, examples). Document each `@param`.
- Provide `outputSchema` for structured outputs; set `ToolAnnotations(readOnlyHint: true)` for non-mutating tools.
- Throw `Mcp\Exception\ToolCallException` (or the SDK's tool exception in use) on bad input; validate and sanitise all inputs.

### Resource / resource template
```php
#[McpResourceTemplate(
    uriTemplate: 'openehr://guides/{category}/{name}',
    name: 'guides',
    description: '…',
    mimeType: 'text/markdown',
)]
public function read(
    #[CompletionProvider(values: ['archetypes', 'templates', 'aql', 'simplified_formats', 'specs', 'howto'])]
    string $category,
    #[CompletionProvider(provider: GuidesCompletionProvider::class)]
    string $name,
): string {
    foreach ([$category, $name] as $segment) {
        if ($segment === '' || !preg_match('/^[\w.-]+$/', $segment)) {
            throw new ResourceReadException(sprintf('Invalid identifier: %s', $segment));
        }
    }
    // …
}
```
Validate every URI segment against a strict regex before touching the filesystem; throw `ResourceReadException` on invalid/missing resources. If the resource type needs explicit registration (e.g. `Guides::addResources($builder)` in `public/index.php`), wire it there.

### Completion provider
Implement `ProviderInterface::getCompletions(string $currentValue): array` in `src/CompletionProviders/`, then reference it from a parameter via `#[CompletionProvider(provider: MyProvider::class)]` (or inline `values: [...]`).

## Step 3: Ground in the spec

Capabilities exposing openEHR data must be spec-aligned — **do not guess**. Use `type_specification_get("<type>")` for RM/AM class detail and `guide_get(...)` for conventions. Track the `development` branch.

## Step 4: Test (Docker dev container)

Add a `tests/<Area>/<Name>Test.php` (namespace `…\Tests\…`, `*Test.php`), mocking external HTTP. Then, from the MCP repo root:

```bash
make up-dev      # once
make install     # once
# clear discovery cache so the new class is picked up (XDG_DATA_HOME defaults to /tmp):
docker compose -f .docker/docker-compose.yml -f .docker/docker-compose.dev.yml exec -u 1000:1000 app rm -rf /tmp/mcp-* 2>/dev/null || true
docker compose -f .docker/docker-compose.yml -f .docker/docker-compose.dev.yml exec -u 1000:1000 app composer test
docker compose -f .docker/docker-compose.yml -f .docker/docker-compose.dev.yml exec -u 1000:1000 app composer check:phpstan
# focused run:
docker compose -f .docker/docker-compose.yml -f .docker/docker-compose.dev.yml exec -u 1000:1000 app vendor/bin/phpunit --filter MyNewTest
```

Confirm the exact cache path and compose invocation against the MCP repo's `AGENTS.md` / `Makefile` before relying on them.

## Step 5: Document & verify exposure

- Update `AGENTS.md` (MCP conventions / tool counts) and `README.md` (capability tables) in the MCP repo.
- Bump tool/prompt/resource counts referenced in the **user-facing plugin** (`openehr-assistant-plugin`) when the public surface changes — see the `release-workflow` skill.
- Optionally run `make conformance` (server must be up via `make up-dev`) to verify the new capability over MCP.

## Checklist
- [ ] Correct directory + attribute for the capability type
- [ ] LLM-oriented PHPDoc description; documented params; `outputSchema` where applicable
- [ ] Input validation + appropriate exception type
- [ ] Spec-grounded (no guessed RM/AM detail)
- [ ] PHPUnit test added, external HTTP mocked
- [ ] Discovery cache cleared; `composer test` + `check:phpstan` green in the dev container
- [ ] `AGENTS.md` / `README.md` updated; plugin counts aligned if the surface changed
