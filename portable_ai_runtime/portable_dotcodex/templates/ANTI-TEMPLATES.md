# ANTI-TEMPLATES

Items we deliberately do NOT pre-fill in templates.

## Deliberately Omitted

- Default lint/format rules
- Default commit message format
- Pre-filled gotchas or anti-patterns
- Default project directory structure
- Concrete business spec samples
- Pre-filled agent names or model choices
- Default MCP server configurations
- Pre-filled skill descriptions (must come from real usage)
- Default token budgets or thresholds
- Pre-filled permission rules

## Principles

1. Structure is reusable, content must not be pre-filled.
2. Before adding anything to a template, ask: "Would two genuinely different projects both agree on this content?"
3. Placeholders: `{{VALUE}}` for mechanical substitution, `<!-- FILL: ... -->` for human/agent judgment.
