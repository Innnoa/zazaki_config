---
type: report-format
usage: Render findings per this structure. N=1 must include candidate banner.
---

# Intuition Probe Report

## Artifact Under Test
- **Artifact:** {{ARTIFACT_PATH}}
- **Sanitized Goal:** {{SANITIZED_GOAL}}
- **N:** {{N}}
- **Mode:** {{cold | doc-informed}}
{{#if N==1}}
> ⚠️ **Candidate Banner:** N=1 — these are candidate shapes, not confirmed familiar defaults. At least 2 converging agents are needed to mark a finding as high-priority.
{{/if}}

## Decision Points

| # | Category | Agent Expected | Answer Key | Classification | Confidence | Recommendation |
|---|----------|---------------|------------|----------------|------------|----------------|
| 1 | api_signature | `validate(input)` | `checkInput(data)` | divergence | high | Rename to `validate` |
| ... | ... | ... | ... | ... | ... | ... |

## Priority Changes (conform-first)

Changes recommended based on guess vs. answer key divergence:
1. **`checkInput` → `validate`** — most validation libraries use `validate()`, high confidence
2. ...

## Convergent Findings (N>1 only)

Decision points where ≥2 agents agreed:
- (empty at N=1)

## Summary

- **Total decision points:** {{TOTAL}}
- **Matches:** {{MATCHES}} (API already aligns with intuition)
- **Divergences:** {{DIVERGENCES}} (conform API to guess)
- **Missing:** {{MISSING}} (consider adding or simplifying)
- **Skipped:** {{SKIPPED}}

## Raw Findings

```json
{{FINDINGS_JSON}}
```
