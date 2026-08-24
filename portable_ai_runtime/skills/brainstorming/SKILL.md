---
name: brainstorming
description: "Use before adding a new feature, changing behavior, or exploring a solution when requirements or design are not yet confirmed"
---

# Brainstorming Ideas Into Designs

Help turn ideas into fully formed designs and specs through natural collaborative dialogue.

## Core Rules

1. **Hard gate** — no implementation until design presented and user approved. Applies to every project regardless of perceived simplicity.
2. **One question at a time** — deep-dive on each topic before moving on. Don't overwhelm with multiple questions.
3. **Environment-first** — explore project context (files, docs, recent commits) before asking questions.
4. **Present options** — always propose 2-3 approaches with trade-offs and a recommendation.
5. **Incremental validation** — present design sections one at a time, get approval before moving on.

## When To Use

- New feature or behavior change when requirements/design are not yet confirmed
- Exploring a solution space before committing to an approach
- User has a vague idea that needs refinement into a concrete design

## Process

1. **Explore project context** — check files, docs, recent commits
2. **Offer visual companion** — if topic involves visual questions (own message, see workflow for details)
3. **Ask clarifying questions** — follow `rules/ai/grill-me-protocol.md`: one at a time, environment-first, depth-first
4. **Propose 2-3 approaches** — with trade-offs and your recommendation
5. **Present design sections** — scale to complexity, get approval per section
6. **Write design doc** — save to `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`, self-review, user review gate
7. **Transition to writing-plans** — the ONLY next skill. Do NOT invoke any other implementation skill.

## Relationship to Other Skills

- **grill-me** — brainstorming is for open-ended idea-to-design. Transitions into grill-me when design narrows to concrete, interdependent trade-offs.
- **writing-plans** — the sole next step. Do not invoke frontend-design, mcp-builder, or any other implementation skill.
- **intuition-probe** — after design converges to concrete interfaces, blind-test for intuitiveness against LLM expectations.

## Workflow & Rules

The detailed procedural workflow (checklist, process flow, design presentation, visual companion) lives at `workflows/ai/brainstorming.md`.
Rule-like constraints (hard gate, anti-patterns, interview rules, scope prevention, design principles) live at `rules/ai/brainstorming-rules.md`.

## 检验句

问自己：`设计已经向用户呈现并获得批准了吗？我是不是在还没有设计的情况下就直接开始实现了？`
如果答案里有任何"应该没问题"或"这个太简单了不需要设计"——回去呈现设计。
