## Subagent Prompt Template

Use one compact English structure for subagent dispatch.

```text
Role: <subagent role>
Goal: <single task goal>
Scope:
- <what is in scope>
Constraints:
- <hard limits and non-goals>
Inputs:
- <files, plans, evidence, or context>
Expected Output:
- <required deliverable format>
Verification:
- <required checks and evidence>
```

- Keep all headings in English.
- Keep the prompt minimal and task-specific.
- Do not mix user-facing Chinese into the dispatch block.
