---
name: grill-me
description: Use when the user needs structured decision-tree exploration, exhaustive requirements clarification, or shared understanding before any implementation. Activates on phrases like "grill me", "interview me", "walk through every decision", "帮我理清", or any task where decisions are interdependent and assumptions must be surfaced one branch at a time.
---

# Grill Me

Interview relentlessly about every aspect until shared understanding is reached. Walk down each branch of the decision tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

## Core Rules

1. **One question at a time** — wait for feedback on each question before continuing. Multiple questions at once is bewildering.
2. **Environment-first** — if a fact can be found by exploring the environment (filesystem, tools, codebase, etc.), look it up rather than asking. The decisions belong to the user — put each one and wait for their answer.
3. **Recommend per question** — for each decision point, provide your recommended answer with brief reasoning.
4. **Tree traversal** — walk down each branch of the decision tree. When a decision opens sub-decisions, follow them before backtracking. Resolve dependencies depth-first.
5. **Hard gate** — do not act until the user confirms shared understanding has been reached.

## When To Use

- Complex multi-decision design where branches depend on each other
- User has domain knowledge but hasn't surfaced all constraints yet
- High-risk choices where unexamined assumptions cause rework
- Pre-implementation alignment: "before we write any code, let's make sure we agree on every decision"

## Process

1. **Explore** — silently explore the environment to gather facts. Read relevant files, config, code structure. Do not ask what you can find.
2. **Map the tree** — identify the root decision and its branches. Begin at the highest-leverage decision point.
3. **Interview** — one question at a time, each with a recommended answer:
   - State the decision point clearly
   - Provide your recommendation with reasoning
   - Ask for confirmation or alternative
4. **Follow branches** — when a decision is made, follow its sub-decisions depth-first before backtracking to siblings.
5. **Confirm closure** — when the tree is exhausted, summarize the decisions made and ask: "Do we have shared understanding? May I proceed?"

## Question Format

```
**Decision: <what needs to be decided>**

Recommended: <your recommendation>
Reason: <why, what trade-offs this implies>

Your call?
```

## Relationship to brainstorming

brainstorming is for turning vague ideas into designs through open-ended dialogue. grill-me is for structured decision-tree traversal when the problem space is known but decisions are interdependent and need exhaustive resolution. You can transition from brainstorming into grill-me when the design phase narrows to concrete trade-offs.

## Protocol

The canonical protocol lives at `rules/ai/grill-me-protocol.md`. This skill file is the user-facing entry point; the protocol is the reusable behavior specification. Any workflow that requires structured user decision-making may also reference the protocol directly.
