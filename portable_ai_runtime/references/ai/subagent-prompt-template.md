## Subagent Prompt Template

Use one compact English structure for subagent dispatch.

```text
Goal: <single task goal — what must be accomplished>
Inputs:
- <files, plans, evidence, or context given to the worker>
Outputs:
- <required deliverable format and content>
Forbidden Zones:
- <hard limits, non-goals, and files/patterns the worker must not touch>
Acceptance Criteria:
- <mechanically verifiable checks — must be something a script or diff can prove>
```

## Contract Rules

- No field may be empty. Skip the dispatch if any field is undefined.
- Acceptance Criteria must be mechanically verifiable. "Code looks clean" is not valid.
- The worker must not modify the contract.
- The worker must not review its own output.

## Format Rules

- Keep all headings in English.
- Keep the prompt minimal and task-specific.
- Do not mix user-facing Chinese into the dispatch block.
