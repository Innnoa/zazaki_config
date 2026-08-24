## 计划编写规则

### 作用

定义 writing-plans 技能的计划编写约束——计划必须满足的结构、格式、粒度与内容要求。本文件是规则层，不包含执行流程或自检步骤（这些在 `workflows/ai/plan-writing.md`）。

### 文件边界规则

- 每个文件应有单一明确职责。优先使用小而专注的文件，避免单个文件承载过多职责。
- 经常一起改动的文件应放在一起。按职责拆分，不按技术层拆分。
- 在已有代码库中遵循既有模式。如果代码库使用大文件，不要单方面重构——但如果正在修改的文件已经膨胀到难以维护，在计划中包含拆分是合理的。
- 当文件结构取舍需要用户参与时（文件边界、架构分叉、依赖选择），遵循 `rules/ai/grill-me-protocol.md`：一次一个决策点，附推荐方案。

### 结构性决策门禁

在进入任务分解之前，必须执行以下检查：

- [ ] 文件边界是否已确定且无争议？
- [ ] 架构分叉（如果有）是否已经用户确认？
- [ ] 依赖选择（库、框架、服务）是否已经用户确认？
- [ ] 是否有任何结构决策停留在"我先假设这样，后面再问"？

任意一项未通过 → 暂停分解，启动 grill-me 访谈，逐项确认后再继续。

检验：每个文件是否只有一个清晰职责？改动边界是否和职责边界对齐？

### 任务分解规则

- **每个步骤一个动作（2-5 分钟）**：写测试是一个步骤，运行验证是一个步骤，实现代码是一个步骤，提交是一个步骤。
- 每个任务产出独立、自包含的变更。
- 不要写"类似任务 N"——后面任务的代码必须完整重复，因为读者可能乱序阅读。
- 不要引用任何任务中未定义的类型、函数或方法。

检验：一个工程师按顺序执行这些步骤时，每个步骤是否可以在 2-5 分钟内完成且不需要跨步骤猜测？

### 计划文档头部规则

每个计划必须以以下头部开头：

```markdown
# [Feature Name] Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

---
```

检验：头部是否包含了 Goal、Architecture、Tech Stack 和 agentic workers 指令？

### 任务结构模板

每个任务遵循以下格式：

```markdown
### Task N: [Component Name]

**Files:**
- Create: `<project>/path/to/file.py`
- Modify: `<project>/path/to/existing.py:123-145`
- Test: `tests/<project>/path/to/test.py`

- [ ] **Step 1: Write the failing test**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

- [ ] **Step 3: Write minimal implementation**

```python
def function(input):
    return expected
```

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature"
```
```

检验：每个 Task 是否包含 Files 清单、checkbox 步骤、代码块和明确的运行命令与预期输出？

### 禁止占位符规则

以下写法一律禁止，出现即视为计划失败：

- "TBD"、"TODO"、"implement later"、"fill in details"
- "Add appropriate error handling" / "add validation" / "handle edge cases"（不给出具体实现）
- "Write tests for the above"（不给出实际测试代码）
- "Similar to Task N"（必须重复代码）
- 描述做什么但不展示怎么做的步骤（代码步骤必须有代码块）
- 引用任何未在计划中定义的类型、函数或方法

检验：全文搜索计划，是否存在以上任一禁止模式？

### 记住

- 始终使用精确文件路径
- 每个修改代码的步骤包含完整代码
- 每条命令附带预期输出
- DRY、YAGNI、TDD，频繁提交

检验：计划中的每一步，工程师是否可以完全按步骤操作而不需要额外猜测？

### 检验句

问自己：`计划中的每一步，工程师是否可以完全按步骤操作而不需要额外猜测？全文是否还存在 TBD/TODO/implement later/类似 Task N 等禁止占位符？`
