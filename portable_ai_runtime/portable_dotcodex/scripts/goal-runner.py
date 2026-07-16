#!/usr/bin/env python3
"""Goal Runner — OpenCode 自主任务编排器。

实现 Plan → Act → Test → Review → Iterate 五阶段闭环，
支持 Token 预算感知、Ctrl+C 安全暂停、断点恢复。

用法：goal-run [--project-dir <路径>]
"""

import json
import os
import signal
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

# ── 配置 ───────────────────────────────────────────────────────

STATE_FILE = "GOAL_STATE.json"
OPENCODE_BIN = "opencode"
DEFAULT_BUDGET = 500000
TOKEN_ESTIMATE_CHARS_PER_TOKEN = 3.0
ITERATION_DELAY_SECONDS = 2
OP_ENCODE_TIMEOUT = 900
TASKS_DIR = os.path.expanduser("~/Projects/tasks")
DEFAULT_VERIFIER_MODEL = "deepseek/deepseek-v4-flash"
DEFAULT_VERIFIER_AGENT = "reviewer"

PHASE_LABELS = {
    "plan":     "规划",
    "act":      "执行",
    "test":     "测试",
    "review":   "审查",
    "wrap_up":  "收尾",
}

PHASE_DESCRIPTIONS = {
    "plan":     "分析目标，拆解为可验证的子任务列表",
    "act":      "按计划修改代码、安装依赖、执行命令",
    "test":     "运行测试和 lint，收集结果",
    "review":   "评估进展，判断是否达成目标",
    "wrap_up":  "预算即将耗尽，写进度报告并保存",
}

STATUS_LABELS = {
    "ready":           "就绪",
    "running":         "运行中",
    "paused":          "已暂停",
    "completed":       "已完成",
    "budget_limited":  "预算耗尽",
}

# ── 信号处理 ───────────────────────────────────────────────────

def _on_signal(signum, frame):
    sig_name = signal.Signals(signum).name
    state = _load_state()
    if state and state.get("status") not in ("completed", "budget_limited", "paused"):
        state["status"] = "paused"
        state["updated_at"] = _now_iso()
        _save_state(state)
        print(f"\n\n  ⏸  收到 {sig_name} 信号，已暂停并保存状态。")
        print(f"      下次执行 goal-run 将从第 {state.get('iteration', 0) + 1} 轮继续。")
    sys.exit(0)

signal.signal(signal.SIGINT, _on_signal)
signal.signal(signal.SIGTERM, _on_signal)


# ── 工具函数 ───────────────────────────────────────────────────

def _now_iso():
    return datetime.now(timezone.utc).isoformat()

def _time_str():
    return datetime.now(timezone.utc).strftime("%H:%M:%S")

def _find_project_root():
    cwd = Path.cwd()
    for p in [cwd] + list(cwd.parents):
        if (p / STATE_FILE).exists():
            return str(p)
        if (p / ".git").is_dir():
            return str(p)
    return str(cwd)


def _resolve_tasks_dir(explicit=None):
    """解析 tasks 目录路径。"""
    if explicit:
        return os.path.expanduser(explicit)
    return TASKS_DIR

def _load_state(path=None):
    fp = Path(path or _find_project_root()) / STATE_FILE
    if not fp.exists():
        return None
    try:
        return json.loads(fp.read_text(encoding="utf-8"))
    except (json.JSONDecodeError, IOError) as e:
        print(f"  ✗ 无法读取 {fp}: {e}", file=sys.stderr)
        return None

def _save_state(state, path=None):
    fp = Path(path or _find_project_root()) / STATE_FILE
    state["updated_at"] = _now_iso()
    fp.write_text(
        json.dumps(state, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )

def _estimate_tokens(text):
    if not text:
        return 0
    return max(1, int(len(text) / TOKEN_ESTIMATE_CHARS_PER_TOKEN))


# ── 历史经验复用 ──────────────────────────────────────────────

EXPERIENCE_MAX_COUNT = 5       # 最多注入几条经验
EXPERIENCE_MAX_CHARS = 2000    # 经验总字符数上限


def _extract_section(content, heading):
    """从 Markdown 内容中提取指定标题下的段落。"""
    lines = content.split("\n")
    in_section = False
    result = []
    for line in lines:
        if line.strip().startswith(f"## {heading}"):
            in_section = True
            continue
        if in_section:
            if line.strip().startswith("## "):
                break
            stripped = line.strip()
            if stripped and not stripped.startswith("{"):
                result.append(stripped)
    if result:
        return "\n".join(result)
    return None


def _keyword_score(task_content, experience_text):
    """简单关键词相关性评分：共现词越多分数越高。"""
    if not task_content or not experience_text:
        return 0
    task_words = set(task_content)
    exp_words = set(experience_text)
    common = task_words & exp_words
    return len(common)


def _load_relevant_experiences(task_content, tasks_dir):
    """扫描历史 COMPLETION.md，提取与当前任务相关的经验。"""
    tasks_path = Path(tasks_dir)
    if not tasks_path.exists():
        return None

    entries = []
    for entry in tasks_path.iterdir():
        if not entry.is_dir() or not entry.name.endswith("_done"):
            continue
        completion_md = entry / "COMPLETION.md"
        if not completion_md.exists():
            continue
        content = completion_md.read_text(encoding="utf-8")
        experience = _extract_section(content, "可复用经验")
        problems = _extract_section(content, "遇到的问题")
        if not experience and not problems:
            continue

        combined = ""
        if experience:
            combined += f"经验: {experience}\n"
        if problems:
            combined += f"踩过的坑: {problems}"

        score = _keyword_score(task_content, combined)
        if score > 0:
            entries.append({
                "task": entry.name.replace("_done", ""),
                "text": combined.strip(),
                "score": score,
            })

    if not entries:
        return None

    entries.sort(key=lambda e: e["score"], reverse=True)
    entries = entries[:EXPERIENCE_MAX_COUNT]

    lines = ["## Historical Experience (from previous completed tasks)"]
    lines.append("")
    lines.append("The following relevant experiences were found in past task reports.")
    lines.append("Learn from them — avoid repeating known mistakes.")
    lines.append("")

    total_chars = 0
    for e in entries:
        block = f"### From task `{e['task']}`\n{e['text']}"
        total_chars += len(block)
        if total_chars > EXPERIENCE_MAX_CHARS:
            break
        lines.append(block)
        lines.append("")

    return "\n".join(lines) if len(lines) > 2 else None


# ── tasks/ 目录扫描与完成标记 ─────────────────────────────────

def _scan_tasks(tasks_dir):
    """扫描 tasks 目录下所有 _pending 状态的任务。
    返回按文件名排序的列表，每项包含 dir、name、content、working_dir。"""
    tasks_path = Path(tasks_dir)
    if not tasks_path.exists():
        return []

    tasks = []
    for entry in sorted(tasks_path.iterdir()):
        if not entry.is_dir() or not entry.name.endswith("_pending"):
            continue
        task_md = entry / "TASK.md"
        if not task_md.exists():
            continue
        content = task_md.read_text(encoding="utf-8")
        if not content.strip():
            continue
        working_dir = _parse_working_dir(content)
        tasks.append({
            "dir": entry,
            "name": entry.name,
            "content": content,
            "working_dir": working_dir,
        })
    return tasks


def _parse_working_dir(content):
    """从 TASK.md 内容中提取工作目录。"""
    in_section = False
    for line in content.split("\n"):
        stripped = line.strip()
        if stripped.startswith("## 工作目录"):
            in_section = True
            continue
        if in_section and stripped.startswith("## "):
            break
        if in_section and stripped and not stripped.startswith("#"):
            # 只接受看起来像路径的行
            path = stripped.lstrip("- `").rstrip("`").strip()
            if path.startswith("/") or path.startswith("~") or path.startswith("."):
                return os.path.expanduser(path) if path.startswith("~") else os.path.abspath(path)
    return None


def _task_index_for_subtask(state, subtask_idx):
    """给定当前 GOAL_STATE 和子任务序号，在 task_map 中找到对应条目。

    task_map 条目可能是字符串（旧格式）或 dict {"name": ..., "working_dir": ...}。
    返回 dict 或 None。"""
    task_map = state.get("task_map")
    if not task_map or not isinstance(task_map, list) or subtask_idx >= len(task_map):
        return None
    entry = task_map[subtask_idx]
    if isinstance(entry, str):
        return {"name": entry, "working_dir": None}
    return entry


def _resolve_working_dir(state, phase, fallback_dir):
    """根据当前执行阶段和 task_map，返回 opencode 应该使用的工作目录。

    规则：
    - PLAN/TEST/REVIEW 阶段：使用第一个 task 的工作目录
    - ACT 阶段：使用当前子任务对应 task 的工作目录
    - 无 task_map 时回退到 fallback_dir"""
    task_map = state.get("task_map")
    if not task_map:
        return fallback_dir

    idx = 0
    plan = state.get("current_plan", [])
    if phase == "act":
        # 找到第一个未完成的子任务序号
        for i, t in enumerate(plan):
            if not t.startswith("✓"):
                idx = i
                break

    entry = _task_index_for_subtask(state, idx)
    if entry and entry.get("working_dir"):
        wd = entry["working_dir"]
        if os.path.isdir(wd):
            return wd
    return fallback_dir


def _mark_task_failed(task_dir, reason=""):
    """将任务文件夹 _pending 重命名为 _failed。"""
    new_name = task_dir.name.replace("_pending", "_failed")
    new_path = task_dir.parent / new_name
    if new_path.exists():
        counter = 1
        while new_path.exists():
            new_name = task_dir.name.replace("_pending", f"_failed_{counter}")
            new_path = task_dir.parent / new_name
            counter += 1
    task_dir.rename(new_path)
    return new_path


def _write_completion_report(task_dir, state):
    """在 task 文件夹写入 COMPLETION.md。"""
    completion_path = task_dir / "COMPLETION.md"
    plan = state.get("current_plan", [])
    criteria = state.get("success_criteria", [])
    history = state.get("history", [])

    lines = [
        "# 完成报告",
        "",
        "## 做了什么",
    ]
    act_entries = [h for h in history if "[ACT]" in h]
    if act_entries:
        for entry in act_entries:
            # fix: lstrip('[ACT] ') also strips 'C' from 'Completed:'
            cleaned = entry.replace('[ACT] ', '', 1).strip()
            lines.append(f"- {cleaned}")
    else:
        lines.append("（见 GOAL_STATE.json 历史记录）")

    lines.append("")
    lines.append("## 完成情况")
    done = sum(1 for t in plan if t.startswith("✓"))
    total = len(plan)
    lines.append(f"子任务进度: {done}/{total}")
    if criteria:
        lines.append("")
        lines.append("验收标准:")
        for c in criteria:
            lines.append(f"- {c}")

    lines.append("")
    lines.append("## 遇到的问题")
    error_entries = [h for h in history if "[ERROR]" in h or "[VERIFY]" in h]
    if error_entries:
        for entry in error_entries:
            lines.append(f"- {entry}")
    else:
        lines.append("无")

    lines.append("")
    lines.append("## 可复用经验")
    # 从 history 中自动提取经验线索
    experiences = []
    for h in history:
        cleaned = h.strip()
        for prefix in ("[ERROR]", "[VERIFY]", "[ACT]"):
            if cleaned.startswith(prefix):
                cleaned = cleaned[len(prefix):].strip()
                break
        if cleaned and len(cleaned) > 5:
            experiences.append(cleaned)
    if experiences:
        deduped = list(dict.fromkeys(experiences))  # 保持顺序去重
        lines.append("（以下由 goal-runner 自动提取，仅供参考）")
        for exp in deduped[-6:]:
            lines.append(f"- {exp}")
    else:
        lines.append("（无记录）")
    lines.append("")

    completion_path.write_text("\n".join(lines), encoding="utf-8")


def _mark_task_done(task_dir):
    """将任务文件夹 _pending 重命名为 _done。"""
    new_name = task_dir.name.replace("_pending", "_done")
    new_path = task_dir.parent / new_name
    if new_path.exists():
        # 如果目标已存在，追加序号
        counter = 1
        while new_path.exists():
            new_name = task_dir.name.replace("_pending", f"_done_{counter}")
            new_path = task_dir.parent / new_name
            counter += 1
    task_dir.rename(new_path)
    return new_path


# ── phase prompt 构建 ──────────────────────────────────────────

def _build_phase_prompt(project_dir, state, phase):
    goal = state.get("goal", "(无)")
    criteria = state.get("success_criteria", [])
    plan = state.get("current_plan", [])
    iteration = state.get("iteration", 0)
    history = state.get("history", [])
    budget_used = state.get("budget_used", 0)
    budget_total = state.get("budget_total", DEFAULT_BUDGET)

    lines = [
        f"You are executing a GOAL-DRIVEN task across multiple iterations.",
        f"This is iteration {iteration + 1} — PHASE: {phase.upper()}.",
        f"",
        f"**CRITICAL: you MUST update GOAL_STATE.json before finishing.**",
        f"",
        f"## Safety Rules",
        f"- NEVER run destructive git commands: no `git restore`, `git reset --hard`, `git clean -f`, `git checkout --`",
        f"- NEVER delete or revert uncommitted changes you did not create",
        f"- Only modify files directly related to the current task",
        f"",
        f"## Goal",
        goal,
        f"",
        f"## Success Criteria",
        *((f"- {c}" for c in criteria) if criteria else ["Not yet defined."]),
        f"",
    ]

    # ── PLAN 阶段：注入 tasks/ 目录内容 ─────────────────────
    if phase == "plan" and not plan:
        task_list = _scan_tasks(state.get("tasks_dir", TASKS_DIR))
        if task_list:
            lines.append("## Pending Tasks from `tasks/` directory")
            lines.append("")
            lines.append("The following tasks were found in the `tasks/` directory.")
            lines.append("Break each into concrete subtasks and verify them individually.")
            lines.append("")
            lines.append("**Important:** when writing `current_plan`, use the EXACT task directory")
            lines.append("name (without path) as the sub-task identifier so the runner can")
            lines.append("match them back to the correct task folder.")
            lines.append("")
            for idx, t in enumerate(task_list, 1):
                lines.append(f"### Task {idx}: `{t['name']}`")
                lines.append(t["content"])
                lines.append("")
            lines.append("## Instructions")
            lines.append("")
            lines.append(f"1. Read all {len(task_list)} task descriptions above.")
            lines.append("2. For each task, create sub-tasks in `current_plan` prefixed with the")
            lines.append("   task folder name, e.g. `tasks/2026-07-01_xxx_pending/: <subtask>`.")
            lines.append(f"3. Do NOT modify the `task_map` field — it was set during bootstrap.")
            lines.append(f"4. Define global `success_criteria` that cover ALL tasks.")
            lines.append(f"5. Set `phase` to \"act\".")
            lines.append("6. Append to history: \"[PLAN] Scanned tasks/ directory, broke down N tasks\"")
            lines.append("7. Do NOT start implementing — planning only.")
            lines.append("")

    lines.extend([
        f"## Current Plan (subtasks)",
        *(plan if plan else ["No plan yet — will be created in the first PLAN phase."]),
        f"",
        f"## Recent History (last 5)",
        *(history[-5:] if history else ["No history yet."]),
        f"",
        f"## Budget",
        f"Used: {budget_used} / Total: {budget_total} tokens",
        f"",
    ])

    # ── ACT 阶段：注入历史经验 ───────────────────────────────
    if phase == "act":
        task_name = state.get("goal", "")
        first_pending = [t for t in plan if not t.startswith("✓")]
        if first_pending:
            task_name = first_pending[0]
        experiences = _load_relevant_experiences(task_name, state.get("tasks_dir", TASKS_DIR))
        if experiences:
            lines.append(experiences)
            lines.append("")
            lines.append("---")
            lines.append("")

    phase_specific = {
        "plan": [
            "## Your Task — PLAN",
            "",
            "1. Read the goal and analyze what needs to be done.",
            "2. Break the goal into concrete, verifiable subtasks (one per line).",
            "3. Define explicit, measurable success criteria.",
            "4. Write these into GOAL_STATE.json:",
            "   - `current_plan`: array of task strings (each task is a single action)",
            "   - `success_criteria`: array of measurable conditions",
            "   - `phase`: \"act\"",
            "   - Append an entry to `history`: \"[PLAN] Broke down goal into N subtasks\"",
            "5. **PRESERVE all other existing fields** — do not delete task_map, tasks_dir, retry_count, or any field you did not create.",
            "6. Do NOT start implementing — planning only.",
        ],
        "act": [
            "## Your Task — ACT",
            "",
            "1. Find the FIRST incomplete subtask in `current_plan`.",
            "2. EXECUTE it: modify code, install dependencies, run commands.",
            "3. When the subtask is done, update GOAL_STATE.json:",
            "   - Mark the subtask with a ✓ prefix",
            "   - `phase`: \"test\"",
            "   - Append to `history`: \"[ACT] Completed: <subtask summary>\"",
            "4. If the subtask cannot be completed, note the blocker in `history`.",
        ],
        "test": [
            "## Your Task — TEST",
            "",
            "1. Run relevant tests, linters, and build commands for the latest changes.",
            "2. If ALL tests pass:",
            "   - `phase`: \"review\"",
            "   - Append to `history`: \"[TEST] All tests passed.\"",
            "3. If tests FAIL:",
            "   - Record failures in `history`: \"[TEST] Failures: <details>\"",
            "   - Keep `phase` as \"act\" so the next iteration retries the failing subtask.",
            "4. If no tests exist for the change, note it and proceed with phase \"review\".",
        ],
        "review": [
            "## Your Task — REVIEW",
            "",
            "1. Compare current progress against ALL success criteria.",
            "2. You MUST check ALL of these:",
            "   - Are all subtasks in `current_plan` completed (✓)?",
            "   - Do all success criteria pass?",
            "   - Were tests run and passed?",
            "3. If ALL criteria are MET:",
            "   - Set `status` to \"completed\" in GOAL_STATE.json",
            "   - Append to `history`: \"[REVIEW] Goal achieved — all criteria met.\"",
            "   - Write a brief completion summary to history.",
            "4. If some criteria are NOT met but progress was made:",
            "   - `phase`: \"plan\" (to re-plan remaining work)",
            "   - Append to `history`: \"[REVIEW] N/M criteria met, continuing.\"",
            "5. If BLOCKED (cannot make progress):",
            "   - Record the blocker clearly in `history`: \"[REVIEW] BLOCKED: <reason>\"",
            "   - `phase`: \"plan\" (to find alternative approach)",
            "6. Be HONEST. Do not claim completion without verification.",
            "   If you are unsure, set phase to \"plan\" for another pass.",
        ],
        "wrap_up": [
            "## Your Task — WRAP UP (Budget Nearly Exhausted)",
            "",
            "Your token budget is almost exhausted.",
            "1. Document what has been completed vs what remains.",
            "2. Write a clear progress summary to GOAL_STATE.json:",
            "   - Set `status` to \"budget_limited\"",
            "   - Append to `history` a detailed wrap-up note.",
            "3. Make the state file clean and readable so the user can resume later.",
            "4. If any subtasks were completed, note them clearly.",
        ],
    }

    lines.extend(phase_specific.get(phase, phase_specific["plan"]))
    return "\n".join(lines)


# ── 执行单轮 opencode run ──────────────────────────────────────

def _run_opencode(project_dir, prompt, model=None, agent=None):
    import threading

    cmd = [
        OPENCODE_BIN, "run",
        "--dangerously-skip-permissions",
        "--dir", project_dir,
    ]
    if model:
        cmd.extend(["--model", model])
    if agent:
        cmd.extend(["--agent", agent])
    cmd.append(prompt)

    try:
        proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    except FileNotFoundError:
        return "", f"未找到 {OPENCODE_BIN}，请先安装 opencode", 1
    except OSError as e:
        return "", str(e), 1

    start = time.time()
    stop_progress = threading.Event()
    notified = [False]

    def _show_progress():
        while not stop_progress.is_set():
            stop_progress.wait(30)
            if not stop_progress.is_set():
                elapsed = int(time.time() - start)
                print(f"       ⏳ 执行中... ({elapsed}s)", flush=True)
                notified[0] = True

    notifier_t = threading.Thread(target=_show_progress, daemon=True)
    notifier_t.start()

    try:
        proc.wait(timeout=OP_ENCODE_TIMEOUT)
    except subprocess.TimeoutExpired:
        proc.kill()
        proc.wait()
        stop_progress.set()
        notifier_t.join(timeout=2)
        return "", f"超时 ({OP_ENCODE_TIMEOUT}s)", 1

    stdout, stderr = proc.communicate()
    stop_progress.set()
    notifier_t.join(timeout=2)

    elapsed = int(time.time() - start)
    if notified[0] or elapsed >= 30:
        print(f"       ✓ 完成 (耗时 {elapsed}s)")

    return stdout, stderr, proc.returncode


# ── 独立验证器 ────────────────────────────────────────────────

def _build_verifier_prompt(project_dir, state):
    """构建独立验证器的 prompt —— 只看证据，不给实现权限。"""
    goal = state.get("goal", "(无)")
    criteria = state.get("success_criteria", [])
    plan = state.get("current_plan", [])
    history = state.get("history", [])

    # 收集 git diff 摘要
    diff_stat = _git_diff_stat(project_dir)
    changed_files = _git_changed_files(project_dir)

    lines = [
        "You are an INDEPENDENT VERIFIER. Your ONLY job is to judge whether the",
        "current GOAL_STATE.json correctly claims completion.",
        "",
        "**CRITICAL RULES:**",
        "- You do NOT implement anything. You only verify.",
        "- You do NOT suggest fixes. You only report pass/fail.",
        "- Be HONEST. If evidence does not support the claim, say FAIL.",
        "- Check for self-deception: deleted tests, skipped criteria, empty changes.",
        "",
        "## Task Goal",
        goal,
        "",
        "## Success Criteria (ALL must be met)",
        *((f"- {c}" for c in criteria) if criteria else ["Not defined — automatic FAIL."]),
        "",
        "## Current Plan Progress",
        *(plan if plan else ["No plan — automatic FAIL."]),
        "",
        "## Agent's Claimed History (last 10)",
        *(history[-10:] if history else ["No history."]),
        "",
        "## Evidence: Git Changes",
    ]

    if changed_files:
        lines.append(f"Changed files ({len(changed_files)}):")
        for f in changed_files:
            lines.append(f"  - {f}")
        if diff_stat:
            lines.append("")
            lines.append(diff_stat)
    else:
        lines.append("NO file changes detected — suspicious if claiming completion.")

    lines.extend([
        "",
        "## Your Task",
        "",
        "1. Check EVERY success criterion against the evidence.",
        "2. Check that ALL subtasks in current_plan are marked ✓.",
        "3. Check that git diff shows actual code changes (not just GOAL_STATE.json edits).",
        "4. Check for deleted or skipped tests (a common self-deception signal).",
        "",
        "If everything passes: set `status` to \"completed\" in GOAL_STATE.json.",
        "Append to history: \"[VERIFIER] Independent verification PASSED.\"",
        "",
        "If anything fails: set `phase` to \"plan\" (NOT \"act\").",
        "Append to history: \"[VERIFIER] FAIL: <specific reasons>\".",
        "Do NOT set status to \"completed\".",
    ])

    return "\n".join(lines)


def _run_verifier(project_dir, state):
    """运行独立验证器：不同模型 + reviewer agent。"""
    prompt = _build_verifier_prompt(project_dir, state)
    verifier_model = state.get("verifier_model", DEFAULT_VERIFIER_MODEL)
    verifier_agent = state.get("verifier_agent", DEFAULT_VERIFIER_AGENT)

    print(f"     🔍 独立验证器启动 (模型: {verifier_model}, agent: {verifier_agent})")
    stdout, stderr, rc = _run_opencode(
        project_dir, prompt,
        model=verifier_model,
        agent=verifier_agent,
    )
    return stdout, stderr, rc


# ── 文件变更检测 ──────────────────────────────────────────────

def _git_changed_files(project_dir):
    """返回本轮修改的文件列表 (git diff --stat 或 --name-only)"""
    try:
        r = subprocess.run(
            ["git", "diff", "--name-only"],
            capture_output=True, text=True, cwd=project_dir, timeout=10,
        )
        files = [f for f in r.stdout.strip().split("\n") if f]
        return files
    except Exception:
        return []


def _git_diff_stat(project_dir):
    """返回 git diff --stat 的简短摘要"""
    try:
        r = subprocess.run(
            ["git", "diff", "--stat"],
            capture_output=True, text=True, cwd=project_dir, timeout=10,
        )
        return r.stdout.strip()
    except Exception:
        return ""


# ── 日志写入 ──────────────────────────────────────────────────

def _write_iter_log(project_dir, iteration, phase, stdout):
    """将本轮 opencode 的完整输出写入日志文件。"""
    log_dir = Path(project_dir) / "outputs" / "goal-runner"
    log_dir.mkdir(parents=True, exist_ok=True)
    log_file = log_dir / f"iter_{iteration + 1:04d}_{phase}.log"
    try:
        log_file.write_text(stdout, encoding="utf-8")
    except Exception:
        pass
    return log_file


# ── 显示单轮执行摘要 ──────────────────────────────────────────

def _show_expected_work(state, phase):
    """显示本轮预计做什么 — 在执行 opencode 之前调用。"""
    plan = state.get("current_plan", [])
    history = state.get("history", [])
    iteration = state.get("iteration", 0)

    if phase == "plan":
        if not plan:
            print(f"     📋 预计: 首次分析目标，拆解为可验证的子任务")
        else:
            print(f"     📋 预计: 根据审查反馈重新规划剩余工作")
    elif phase == "act":
        pending = [t for t in plan if not t.startswith("✓")]
        if pending:
            task = pending[0].lstrip("✓ ").strip()
            print(f"     📋 预计: 执行子任务 —— {task}")
        else:
            print(f"     📋 预计: 执行下一个未完成的子任务")
    elif phase == "test":
        # Show what was just done in the act phase
        last_act = [h for h in history if h.startswith("[ACT]")]
        if last_act:
            print(f"     📋 预计: 测试上一轮的修改 ({last_act[-1].split('Completed: ')[-1] if 'Completed:' in last_act[-1] else 'verify changes'})")
        else:
            print(f"     📋 预计: 运行测试和 lint，收集结果")
    elif phase == "review":
        done = sum(1 for t in plan if t.startswith("✓"))
        total = len(plan)
        print(f"     📋 预计: 评估进展 ({done}/{total} 子任务已完成)，判断是否达标")
    elif phase == "wrap_up":
        print(f"     📋 预计: 预算即将耗尽，写进度报告并保存")
    print()


def _show_iteration_summary(state_before, state_after, phase, budget_spent, project_dir):
    """对比前后状态，显示本轮实际做了什么。"""
    hist_before = set(state_before.get("history", []))
    hist_after  = set(state_after.get("history", []))
    new_entries = [h for h in state_after.get("history", []) if h not in hist_before]

    plan_before = state_before.get("current_plan", [])
    plan_after  = state_after.get("current_plan", [])
    phase_cn = PHASE_LABELS.get(phase, phase)
    task_count = len(plan_after)
    plan_completed = sum(1 for t in plan_after if t.startswith("✓"))

    print(f"     ✅ 实际: ({phase_cn}阶段完成 · 本轮消耗约 {budget_spent:,} token)")

    # 输出 AI 自述的历史条目
    if new_entries:
        for entry in new_entries:
            print(f"        {entry}")

    # plan 阶段: 显示拆解出的子任务
    if phase == "plan" and plan_after and not plan_before:
        print(f"        子任务列表:")
        for idx, t in enumerate(plan_after, 1):
            done = "✓" if t.startswith("✓") else " "
            desc = t.lstrip("✓").strip()
            print(f"          [{done}] {idx}. {desc}")

    # act 阶段: 显示任务进度
    if phase == "act":
        print(f"        子任务进度: {plan_completed}/{task_count}")

    # 文件变更
    if phase in ("act", "test"):
        changed = _git_changed_files(project_dir)
        if changed:
            stat = _git_diff_stat(project_dir)
            print(f"        📝 文件变更:")
            for line in stat.split("\n")[:8]:
                print(f"           {line}")

    print()


# ── 独立验证 ──────────────────────────────────────────────────

def _verify_completion(state, project_dir):
    """在 AI 声称完成后，runner 自己做一遍独立机械校验。

    verifier 已做 AI 级审查，这里只做形式校验（子任务标记、验收标准存在性）。
    不再严格检查 git diff — 文件创建类任务可能无代码变更。"""
    issues = []
    plan = state.get("current_plan", [])
    criteria = state.get("success_criteria", [])

    # 1. 所有子任务是否都标记了 ✓
    undone = [t for t in plan if not t.startswith("✓")]
    if undone:
        issues.append(f"子任务未全部完成: {len(undone)}/{len(plan)} 项未标记 ✓ ({', '.join(undone[:3])})")
    elif not plan:
        issues.append("current_plan 为空 — 没有定义任何子任务")

    # 2. 验收标准是否非空
    if not criteria:
        issues.append("success_criteria 为空 — AI 未定义明确的验收标准")

    return len(issues) == 0, issues


# ── 成果摘要写入 ──────────────────────────────────────────────

def _write_outcome(state, project_dir, verified):
    """在 runner 结束前，将成果摘要写入 GOAL_STATE.json。"""
    plan = state.get("current_plan", [])
    criteria = state.get("success_criteria", [])

    # 收集本轮修改的文件（自 runner 启动以来）
    changed_files = _git_changed_files(project_dir)

    outcome = {
        "status": state.get("status"),
        "completed_at": _now_iso(),
        "goal": state.get("goal"),
        "total_iterations": state.get("iteration", 0),
        "total_tokens": state.get("budget_used", 0),
        "subtasks_completed": sum(1 for t in plan if t.startswith("✓")),
        "subtasks_total": len(plan),
        "criteria_defined": len(criteria),
        "changed_files": changed_files,
        "verified": verified,
        "log_dir": "outputs/goal-runner/",
    }

    # 生成为人可读的简短总结
    lines = []
    status_cn = STATUS_LABELS.get(outcome["status"], outcome["status"])
    lines.append(f"目标: {outcome['goal']}")
    lines.append(f"状态: {status_cn}")
    lines.append(f"执行轮次: {outcome['total_iterations']} 轮 · 消耗 {outcome['total_tokens']:,} token")
    lines.append(f"子任务: {outcome['subtasks_completed']}/{outcome['subtasks_total']} 已完成")
    lines.append(f"验收标准: {outcome['criteria_defined']} 条")
    if changed_files:
        lines.append(f"修改文件 ({len(changed_files)} 个):")
        for f in changed_files[:15]:
            lines.append(f"  - {f}")
        if len(changed_files) > 15:
            lines.append(f"  ... 共 {len(changed_files)} 个文件")
    elif outcome["status"] == "completed":
        lines.append("修改文件: 无变更 (仅状态文件)")
    lines.append(f"详细日志: {outcome['log_dir']}")
    outcome["summary_text"] = "\n".join(lines)

    state["outcome"] = outcome
    _save_state(state, project_dir)
    return outcome


# ── 主循环 ─────────────────────────────────────────────────────

def main():
    project_dir = _find_project_root()
    tasks_dir = None
    working_dir = project_dir

    args = sys.argv[1:]
    i = 0
    while i < len(args):
        if args[i] in ("--project-dir", "-d") and i + 1 < len(args):
            project_dir = args[i + 1]
            i += 2
        elif args[i] in ("--tasks-dir", "-t") and i + 1 < len(args):
            tasks_dir = args[i + 1]
            i += 2
        else:
            i += 1

    tasks_dir = _resolve_tasks_dir(tasks_dir)
    os.chdir(project_dir)

    # ── 启动横幅 ───────────────────────────────────────────────

    print()
    print("╔" + "═" * 58 + "╗")
    print("║" + "  🎯  Goal Runner — OpenCode 自主任务编排器".ljust(44) + "║")
    print("╚" + "═" * 58 + "╝")
    print(f"  项目目录 : {project_dir}")
    print(f"  任务目录 : {tasks_dir}")
    print(f"  状态文件 : {project_dir}/{STATE_FILE}")
    print(f"  运行日志 : {project_dir}/outputs/goal-runner/iter_*.log")
    print()

    state = _load_state(project_dir)

    # ── 陈旧状态覆盖：如果 GOAL_STATE.json 已完成但 tasks 目录有新待办 ──
    st = state.get("status") if state else None
    pending_tasks = _scan_tasks(tasks_dir)
    if state and st in ("completed", "budget_limited") and pending_tasks:
        print(f"  ℹ️  GOAL_STATE.json 状态为 {st}，但 {tasks_dir} 下有 {len(pending_tasks)} 个待办")
        print(f"     跳过旧状态，重新从 tasks 引导")
        print()
        state = None

    if state is None:
        if pending_tasks:
            print(f"  ℹ️  检测到 {tasks_dir} 下有 {len(pending_tasks)} 个待办任务，自动创建 GOAL_STATE.json")
            task_names = [t["name"] for t in pending_tasks]
            task_map_entries = [
                {"name": t["name"], "working_dir": t.get("working_dir") or project_dir}
                for t in pending_tasks
            ]
            first_working_dir = pending_tasks[0].get("working_dir") or project_dir
            state = {
                "goal": f"执行 {len(pending_tasks)} 个任务: {', '.join(task_names)}",
                "status": "ready",
                "phase": "plan",
                "iteration": 0,
                "budget_total": DEFAULT_BUDGET,
                "budget_used": 0,
                "current_plan": [],
                "success_criteria": [],
                "history": [],
                "task_map": task_map_entries,
                "tasks_dir": tasks_dir,
                "retry_count": 0,
                "max_retries": 3,
                "created_at": _now_iso(),
                "updated_at": _now_iso(),
            }
            _save_state(state, first_working_dir)
            project_dir = first_working_dir
            working_dir = first_working_dir
        else:
            print("  ✗ 当前项目没有 GOAL_STATE.json。")
            print('    请先在 OpenCode TUI 中输入 /goal "你的目标描述" 来创建目标。')
            print(f"    或者使用 /task 命令在 {tasks_dir} 下创建待办任务。")
            print()
            sys.exit(1)

    # ── 终端状态检查 ───────────────────────────────────────────

    resume = st == "paused"
    if resume:
        print(f"  ▶️  恢复之前暂停的目标")
    else:
        print(f"  ▶️  启动新目标")
    print(f"     目标 : {state['goal']}")

    state["status"] = "running"
    state["updated_at"] = _now_iso()
    _save_state(state, project_dir)

    # ── 迭代变量 ───────────────────────────────────────────────

    iteration = state.get("iteration", 0)
    budget_total = state.get("budget_total", DEFAULT_BUDGET)
    budget_used = state.get("budget_used", 0)
    phase = state.get("phase", "plan")

    print(f"     Token 预算 : {budget_used:,} / {budget_total:,}")
    print(f"     起始轮次 : 第 {iteration + 1} 轮 ({PHASE_LABELS.get(phase, phase)}阶段)")
    print(f"     按 Ctrl+C 可随时暂停，下次执行 goal-run 自动恢复")
    print()
    print("─" * 60)

    if iteration == 0 and not state.get("current_plan"):
        task_count = len(_scan_tasks(tasks_dir))
        if task_count > 0:
            print(f"  ℹ️  首次执行 — 检测到 tasks/ 目录下 {task_count} 个待办任务")
            print(f"     将从「规划」阶段开始，AI 逐一拆解并执行")
        else:
            print("  ℹ️  首次执行 — 将从「规划」阶段开始，由 AI 拆解目标。")
        phase = "plan"

    # ── 主循环 ─────────────────────────────────────────────────

    while state.get("status") == "running":
        budget_pct = budget_used / budget_total if budget_total > 0 else 0
        if budget_pct >= 0.90:
            phase = "wrap_up"

        phase_cn = PHASE_LABELS.get(phase, phase)
        phase_desc = PHASE_DESCRIPTIONS.get(phase, "")

        print(f"\n  [{_time_str()}] 第 {iteration + 1} 轮 · {phase_cn}阶段 · 预算 {budget_pct:.0%}")
        print(f"         {phase_desc}")

        _show_expected_work(state, phase)

        state_before = json.loads(json.dumps(state))  # deep copy

        # ── 根据当前任务解析工作目录 ──────────────────────────
        effective_dir = _resolve_working_dir(state, phase, project_dir)

        if phase == "review":
            stdout, stderr, rc = _run_verifier(effective_dir, state)
            tokens_prompt = 0
        else:
            prompt = _build_phase_prompt(project_dir, state, phase)
            tokens_prompt = _estimate_tokens(prompt)
            stdout, stderr, rc = _run_opencode(effective_dir, prompt)

        if rc != 0:
            retry_count = state.get("retry_count", 0) + 1
            max_retries = state.get("max_retries", 3)
            state["retry_count"] = retry_count
            print(f"  ✗ opencode run 执行失败 (rc={rc}, retry {retry_count}/{max_retries})")
            if stderr:
                print(f"    {stderr[:300]}")

            if retry_count >= max_retries:
                # ── 重试耗尽，标记任务为 _failed ─────────────────
                tasks_root = state.get("tasks_dir", TASKS_DIR)
                plan = state.get("current_plan", [])
                first_pending = [t for t in plan if not t.startswith("✓")]
                if first_pending:
                    # 从 task_map 找到对应文件夹
                    for i, t in enumerate(plan):
                        if not t.startswith("✓"):
                            entry = _task_index_for_subtask(state, i)
                            if entry:
                                task_dir = Path(tasks_root) / entry["name"]
                                if task_dir.exists():
                                    _write_completion_report(task_dir, state)
                                    _mark_task_failed(task_dir)
                                    print(f"     ⛔ 任务已标记为 _failed: {entry['name']}")
                            break
                state["status"] = "paused"
                state["history"] = state.get("history", []) + [
                    f"[ERROR] 执行失败 {retry_count} 次，已标记为 _failed"
                ]
            else:
                state["status"] = "paused"
                state["history"] = state.get("history", []) + [
                    f"[ERROR] 第 {iteration+1} 轮执行失败: {stderr[:200]}"
                ]
            _save_state(state, effective_dir)
            print("  ⏸  已保存状态。执行 goal-run 可重试。")
            sys.exit(1)

        tokens_response = _estimate_tokens(stdout)
        tokens_this_iter = tokens_prompt + tokens_response
        budget_used += tokens_this_iter

        log_path = _write_iter_log(project_dir, iteration, phase, stdout)

        state = _load_state(project_dir)
        if state is None:
            print("  ✗ GOAL_STATE.json 丢失或损坏，退出。")
            sys.exit(1)

        state["budget_used"] = budget_used
        state["iteration"] = iteration + 1
        _save_state(state, project_dir)

        _show_iteration_summary(state_before, state, phase, tokens_this_iter, project_dir)

        # ── 终止条件 ───────────────────────────────────────────

        status = state.get("status")
        if status == "completed":
            print()
            print("  🔍 AI 声称目标已达成，开始独立验证...")
            passed, issues = _verify_completion(state, project_dir)

            plan = state.get("current_plan", [])
            done = sum(1 for t in plan if t.startswith("✓"))

            if not passed:
                print(f"  ⚠️  独立验证发现 {len(issues)} 个问题，回退继续执行:")
                for issue in issues:
                    print(f"       ✗ {issue}")
                state["status"] = "running"
                state["phase"] = "plan"
                state["history"] = state.get("history", []) + [
                    f"[VERIFY] 独立验证失败: {'; '.join(issues)}"
                ]
                _save_state(state, project_dir)
                print()
                phase = "plan"
                iteration += 1
                continue

            # 验证通过
            print(f"  🔍 独立验证通过")
            print(f"      子任务: {done}/{len(plan)} 全部完成")
            print(f"      验收标准: {len(state.get('success_criteria', []))} 条已定义")
            print()

            # ── 标记 Task 文件夹完成 ───────────────────────────
            task_map = state.get("task_map")
            if task_map:
                tasks_root = state.get("tasks_dir", TASKS_DIR)
                print(f"  📁 写入任务完成报告 (路径: {tasks_root})...")
                for entry in task_map:
                    task_name = entry["name"] if isinstance(entry, dict) else entry
                    task_dir = Path(tasks_root) / task_name
                    if task_dir.exists() and task_dir.is_dir():
                        _write_completion_report(task_dir, state)
                        new_path = _mark_task_done(task_dir)
                        print(f"      ✓ {new_path.name}")
                print()

            _write_outcome(state, project_dir, verified=True)
            print("═" * 60)
            print(f"  ✅  目标达成！")
            print(f"      总轮次 : {iteration + 1}")
            print(f"      子任务 : {done}/{len(plan) if plan else '?'} 已完成")
            print(f"      Token  : {budget_used:,}")
            print(f"      完整日志 : outputs/goal-runner/")
            print(f"      回到 OpenCode 运行 /goal-outcome 查看详情")
            print("═" * 60)
            print()
            break

        if budget_pct >= 1.0:
            state["status"] = "budget_limited"
            _save_state(state, project_dir)
            _write_outcome(state, project_dir, verified=False)
            print(f"  ⚠️  Token 预算已耗尽 ({budget_used:,}/{budget_total:,})")
            print(f"     状态已保存，可增加预算后继续: /goal budget <token数>")
            print(f"     回到 OpenCode 运行 /goal-outcome 查看已完成部分")
            print()
            break

        if state.get("status") != "running":
            print(f"  状态变更: {STATUS_LABELS.get(state.get('status'), state.get('status'))}")
            break

        # ── 推进阶段 ───────────────────────────────────────────

        next_map = {"plan": "act", "act": "test", "test": "review", "review": "plan"}
        next_phase = next_map.get(phase, "plan")
        state["phase"] = next_phase
        _save_state(state, project_dir)

        phase = next_phase
        iteration += 1
        time.sleep(ITERATION_DELAY_SECONDS)


if __name__ == "__main__":
    main()
