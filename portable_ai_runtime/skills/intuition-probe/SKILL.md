---
name: intuition-probe
description: Use when you want to know whether your API, config, CLI, or UI feels intuitive to a developer meeting it for the first time. Blind-tests the shape developers reach for before showing them the real thing. Triggers on "is this intuitive", "would a developer guess this", "intuition probe", "blind-test this API/config/CLI", "test the DX/UX", "直觉探测", "盲测这个API".
---

# Intuition Probe

Discover the shape a developer reaches for when they meet your API, config, CLI, or UI for the first time. A blind agent guesses how to use the artifact before seeing the real thing. The guess is not an error to grade; it is a design proposal. Where the guess diverges, the default move is to conform the design to the guess.

## Core Principle

You only hear from the few users who push through an unfamiliar design, but an LLM shows you what people reach for cheaply and at volume. Make the API whatever the LLM guesses.

## Procedure Summary

1. Gather inputs: artifact under test, rough goal, optional read-set, N (default 1)
2. Sanitize the goal: strip leaked identifiers, confirm with user
3. Freeze the blind prompt before reading the answer key
4. Read the answer key (real API surface) privately
5. Spawn N blind agents with the frozen prompt
6. Score guesses against the answer key
7. (N>1) Cluster and cross-validate
8. Report with conform-first recommendations

## Honest Limits

- N=1 gives candidates, not confirmation
- N>1 convergence is required for high-confidence findings
- A correct guess does not prove intuitive design — it may be luck

## Assets

The full procedure lives in `rules/ai/intuition-probe-protocol.md`. Supporting assets:
- `references/intuition-probe/blind-agent-prompt.md` — the frozen prompt template
- `references/intuition-probe/scorer-rubric.md` — guess classification rubric
- `references/intuition-probe/report-format.md` — output report format

## Relationship to grill-me

- **grill-me** interviews the human designer about their decisions
- **intuition-probe** interviews LLMs about what users would expect
- **Together:** grill-me locks design decisions → intuition-probe validates against developer intuition → conform where the guess is more familiar
