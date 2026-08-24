# Brainstorming Rules

Rule-like constraints extracted from the brainstorming skill. These are the "must do" and "must not do" constraints that govern brainstorming sessions.

## Hard Gate

Do NOT invoke any implementation skill, write any code, scaffold any project, or take any implementation action until you have presented a design and the user has approved it. This applies to EVERY project regardless of perceived simplicity.

## Anti-Pattern: "This Is Too Simple to Need a Design"

Every project goes through this process. A todo list, a single-function utility, a config change — all of them. "Simple" projects are where unexamined assumptions cause the most wasted work. The design can be short (a few sentences for truly simple projects), but you MUST present it and get approval.

## Interview Rules

1. **One question at a time** — don't overwhelm with multiple questions. If a topic needs more exploration, break it into multiple questions.
2. **Multiple choice preferred** — easier to answer than open-ended when possible.
3. **Environment-first** — look up what you can before asking. Follow `rules/ai/grill-me-protocol.md` for the full protocol.
4. **Recommended answer per question** — provide your recommendation with brief reasoning.
5. **Depth-first traversal** — walk down each branch of the decision tree before backtracking.

### Decision Gate

在进入 "Propose 2-3 approaches" 阶段之前，必须执行以下门禁检查：

- [ ] 是否已识别所有需要用户确认的决策点？
- [ ] 是否已逐一遍历并得到用户确认？
- [ ] 是否有任何"我觉得用户大概会这样选"的假设未经确认？

任意一项未通过 → 返回访谈阶段，继续提问。不得跳过。

## Scope & Decomposition Rules

- Before asking detailed questions, assess scope. If the request describes multiple independent subsystems (e.g., "build a platform with chat, file storage, billing, and analytics"), flag this immediately.
- Don't spend questions refining details of a project that needs to be decomposed first.
- For oversized projects, help the user decompose into sub-projects: identify independent pieces, their relationships, and build order.
- Each sub-project gets its own spec → plan → implementation cycle.
- For appropriately-scoped projects, proceed through the normal design flow.

## Design Constraints

### Isolation and Clarity

- Break the system into smaller units that each have one clear purpose, communicate through well-defined interfaces, and can be understood and tested independently.
- For each unit, answer: what does it do, how do you use it, and what does it depend on?
- Can someone understand what a unit does without reading its internals? Can you change the internals without breaking consumers? If not, fix the boundaries.
- When a file grows large, that's often a signal that it's doing too much.

### Working in Existing Codebases

- Explore the current structure before proposing changes. Follow existing patterns.
- Where existing code has problems that affect the work, include targeted improvements as part of the design — not unrelated refactoring.
- Stay focused on what serves the current goal.

### Design Coverage

Always cover: architecture, components, data flow, error handling, testing.

## Transition Rules

- The ONLY next skill after brainstorming is **writing-plans**.
- Do NOT invoke frontend-design, mcp-builder, or any other implementation skill.
- After design converges to concrete interfaces, run a lightweight single-agent intuition check:
  1. Ask yourself: "If I were a developer seeing this API/config/CLI for the first time, what would I reach for?"
  2. Write down your guess (method names, param order, config keys, etc.)
  3. Compare against the actual design
  4. If there are deviations, prefer aligning the interface to the guess (per `rules/ai/intuition-probe-protocol.md` core principle)
  5. This takes ~2 minutes and does not require multi-agent dispatch
- For higher-stakes interfaces, consider the full multi-agent blind-test via the `intuition-probe` skill.

#### When Operating Inside Vibe Runtime

When brainstorming is invoked as part of the `vibe` 6-stage managed runtime (skeleton_check → deep_interview → requirement_doc → xl_plan → plan_execute → phase_cleanup), the brainstorming output feeds into vibe's `requirement_doc` stage rather than standalone `writing-plans`. The standalone transition path (`brainstorming → writing-plans → plan-and-implement`) applies only when brainstorming is invoked outside the vibe runtime.

## Key Principles

- **One question at a time** — deep-dive, not a survey
- **Multiple choice preferred** — easier to answer than open-ended when possible
- **YAGNI ruthlessly** — remove unnecessary features from all designs
- **Explore alternatives** — always propose 2-3 approaches before settling
- **Incremental validation** — present design, get approval before moving on
- **Be flexible** — go back and clarify when something doesn't make sense

## 检验句

问自己：`在问下一个问题、呈现设计方案、或开始任何实现之前，当前这一步的约束是否都已满足？`
如果跳过了某条规则（比如一次性问了两个问题、还没呈现设计就想写代码）——退回去按规则重来。
