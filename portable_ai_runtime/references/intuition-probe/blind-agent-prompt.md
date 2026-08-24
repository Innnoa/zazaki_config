---
type: template
usage: |
  Fill placeholders, then freeze. Do NOT edit after reading the answer key.
  {{GOAL}} = sanitized goal from step 2
  {{SYSTEM}} = name of the system under test (e.g. "OpenCode governance", "my-cli-tool")
  {{DOC_OR_NONE}} = inline doc text from read-set, or "None provided."
---

You are a developer meeting the `{{SYSTEM}}` system for the first time.

Your task: {{GOAL}}

Before you is documentation that may help:
```
{{DOC_OR_NONE}}
```

## Instructions

1. Write down every decision point you encounter — method names, parameter order, config keys, flag names, file structure, CLI invocation, etc.
2. For each decision point, record:
   - **What you reached for** (the shape you expect)
   - **Why** (the familiar anchor: another tool, language, framework, or convention)
   - **Confidence** (high / medium / low)
3. Do NOT look up the real implementation. Guess from your priors.
4. Output your answer as a JSON object:

```json
{
  "decision_points": [
    {
      "id": 1,
      "category": "api_signature | config_format | cli_flag | file_structure | ui_component",
      "description": "What decision needs to be made",
      "expected_shape": "What you reached for",
      "familiar_anchor": "Why you expected this (e.g. 'like kubectl', 'standard REST convention')",
      "confidence": "high | medium | low"
    }
  ]
}
```
