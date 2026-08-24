---
type: rubric
usage: Score each agent's `decision_points` against the answer key. Classify every guess.
---

# Scorer Rubric

## Classification

For each guess in the agent's `decision_points`, compare against the answer key:

| Classification | Definition | Implication |
|---------------|------------|-------------|
| `match` | Guess matches the real API exactly (name, shape, order) | Good signal — API aligns with developer intuition |
| `semantic_match` | Different name but same concept / structure | Mild divergence — consider renaming if guess is more familiar |
| `divergence` | Guess uses different shape (naming, structure, invocation pattern) | **Conform-first**: change API to match guess |
| `missing` | Agent did not guess this decision point | Real API has a concept the agent didn't expect — consider removing or simplifying |
| `extra` | Agent guessed something the real API doesn't have | The guess reveals a missing feature or a concept worth adding |
| `not_applicable` | Cannot classify (e.g. guess is too vague) | Skip |

## Confidence Weighting

Multiply classification signal by agent confidence:

| Agent Confidence | Weight |
|-----------------|--------|
| `high` | 1.0 |
| `medium` | 0.5 |
| `low` | 0.2 |

## Findings JSON Format

```json
{
  "findings": [
    {
      "decision_point_id": 1,
      "classification": "divergence",
      "agent_expected": "`validate(input)`",
      "answer_key": "`checkInput(data)`",
      "familiar_anchor": "Most validation libraries use `validate()`",
      "confidence": "high",
      "weighted_signal": 1.0,
      "recommendation": "Rename `checkInput` → `validate` to align with developer intuition"
    }
  ],
  "summary": {
    "total_decisions": 5,
    "matches": 2,
    "divergences": 2,
    "missing": 1,
    "priority_changes": ["Rename `checkInput` → `validate`"]
  }
}
```

## Priority Threshold

At N=1, mark all `divergence` and `missing` findings. At N>1, `priority` only if ≥2 agents agree.
