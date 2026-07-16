#!/usr/bin/env python3
"""daily-report — 按日期聚合任务完成情况与 Git 活动，生成纯文本日报。

用法: python3 daily-report.py [YYYY-MM-DD]
"""

import os
import sys
import subprocess
from datetime import datetime, timezone
from pathlib import Path

TASKS_DIR = Path.home() / "Projects" / "tasks"
PROJECTS_DIR = Path.home() / "Projects"
OUTPUT_DIR = Path.home() / "docs" / "daily"
EXCLUDED_DIRS = {"tasks", "codex-session-audit"}

SEP = "─" * 40
BANNER_SEP = "═" * 40


def parse_date(arg=None):
    if arg:
        try:
            return datetime.strptime(arg, "%Y-%m-%d").date()
        except ValueError:
            print(f"日期格式错误: {arg}，应为 YYYY-MM-DD", file=sys.stderr)
            sys.exit(1)
    return datetime.now().date()


def find_git_repos(root):
    repos = []
    if not root.is_dir():
        return repos
    for entry in sorted(root.iterdir()):
        if not entry.is_dir() or entry.name.startswith("."):
            continue
        if entry.name in EXCLUDED_DIRS:
            continue
        git_dir = entry / ".git"
        if git_dir.exists():
            repos.append(entry)
    return repos


def get_daily_commits(repo, date_str):
    try:
        r = subprocess.run(
            [
                "git", "-C", str(repo), "log",
                "--since", f"{date_str} 00:00:00",
                "--until", f"{date_str} 23:59:59",
                "--format=%nCOMMIT%n%H%n%aI%n%s",
                "--stat",
            ],
            capture_output=True, text=True, timeout=15,
        )
        if r.returncode != 0:
            return []
    except (subprocess.TimeoutExpired, OSError):
        return []

    commits = []
    current = None
    field_idx = 0
    for line in r.stdout.strip().split("\n"):
        line = line.rstrip()
        if not line:
            continue
        if line == "COMMIT":
            if current:
                commits.append(current)
            current = {"hash": "", "time": "", "subject": "", "files": []}
            field_idx = 0
        elif current is not None:
            if field_idx == 0:
                current["hash"] = line
            elif field_idx == 1:
                current["time"] = line.split("T")[1].split("+")[0].split("-")[0][:8]
            elif field_idx == 2:
                current["subject"] = line
            else:
                if "|" in line:
                    fname = line.split("|")[0].strip()
                    if fname:
                        current["files"].append(fname)
                continue
            field_idx += 1
    if current:
        commits.append(current)
    return commits


def read_task_file(task_dir, filename):
    filepath = task_dir / filename
    if not filepath.exists():
        return None
    return filepath.read_text(encoding="utf-8")


def extract_field(content, field_name):
    if not content:
        return None
    in_section = False
    lines_buf = []
    for line in content.split("\n"):
        stripped = line.strip()
        if stripped.startswith(f"## {field_name}"):
            in_section = True
            continue
        if in_section:
            if stripped.startswith("## ") and not stripped.startswith(f"## {field_name}"):
                break
            if stripped:
                lines_buf.append(stripped.lstrip("- ").strip())
    return "\n".join(lines_buf) if lines_buf else None


def scan_tasks(date):
    prefix = date.strftime("%Y-%m-%d")
    done, pending, failed = [], [], []

    if not TASKS_DIR.is_dir():
        return done, pending, failed

    for entry in sorted(TASKS_DIR.iterdir()):
        if not entry.is_dir() or not entry.name.startswith(prefix):
            continue
        name = entry.name

        task_content = read_task_file(entry, "TASK.md")
        completion_content = read_task_file(entry, "COMPLETION.md")

        goal = extract_field(task_content, "目标") if task_content else None
        working_dir = extract_field(task_content, "工作目录") if task_content else None

        summary = None
        done_what = None
        problems = None
        if completion_content:
            summary = extract_field(completion_content, "完成情况")
            done_what = extract_field(completion_content, "做了什么")
            problems = extract_field(completion_content, "遇到的问题")

        info = {
            "name": name,
            "goal": goal or "(无目标说明)",
            "working_dir": working_dir,
            "summary": summary,
            "done_what": done_what,
            "problems": problems,
        }

        if name.endswith("_done"):
            done.append(info)
        elif name.endswith("_failed") or "_failed_" in name:
            info["failed_reason"] = problems or "(未记录失败原因)"
            failed.append(info)
        else:
            pending.append(info)

    return done, pending, failed


def _slug_from_name(name):
    """从文件夹名提取 slug: YYYY-MM-DD_slug_status → slug"""
    parts = name.split("_", 1)
    if len(parts) <= 1:
        return name
    slug = parts[1]
    for suffix in ("_done", "_pending", "_failed"):
        slug = slug.rsplit(suffix, 1)[0]
    if len(slug) > 30:
        slug = slug[:30]
    return slug


def build_headline(done, pending, repo_commits):
    parts = []
    if done:
        parts.append(f"{len(done)}个完成")
    if pending:
        slugs = [_slug_from_name(t["name"]) for t in pending[:3]]
        parts.append(f"{len(pending)}个进行中({', '.join(slugs)})")
    total_commits = sum(len(cs) for cs in repo_commits.values())
    active_repos = [r for r, cs in repo_commits.items() if cs]
    if active_repos:
        repo_names = [Path(r).name for r in active_repos[:5]]
        parts.append(f"{len(active_repos)}仓{total_commits}次提交({', '.join(repo_names)})")
    if not parts:
        return "今日无活动"

    headline = "，".join(parts)

    if done:
        keywords = [_slug_from_name(t["name"]) for t in done[:4]]
        head = " — " + "、".join(keywords)
        if len(headline + head) <= 200:
            headline += head

    return headline


def build_report(date, done, pending, failed, repo_commits):
    lines = []
    date_str = date.strftime("%Y-%m-%d")
    weekday = ["周一", "周二", "周三", "周四", "周五", "周六", "周日"][date.weekday()]

    lines.append(BANNER_SEP)
    lines.append(f"  DAILY REPORT — {date_str} {weekday}")
    lines.append(BANNER_SEP)
    lines.append("")
    lines.append(f"  {build_headline(done, pending, repo_commits)}")
    lines.append("")

    total_done = len(done)
    total_pending = len(pending)
    total_failed = len(failed)
    has_tasks = total_done + total_pending + total_failed > 0

    if has_tasks:
        lines.append(f"[任务]  {total_done} 已完成, {total_pending} 进行中, {total_failed} 失败")

    for t in done:
        lines.append("")
        lines.append(f"  ✓ {t['name']}")
        if t["goal"]:
            lines.append(f"    目标: {t['goal']}")
        if t["summary"]:
            lines.append(f"    完成: {t['summary']}")
        if t["done_what"]:
            for dw in t["done_what"].split("\n"):
                dw = dw.strip()
                if dw:
                    lines.append(f"      - {dw}")
        if t["problems"]:
            lines.append(f"    问题: {t['problems']}")

    for t in pending:
        lines.append("")
        lines.append(f"  ○ {t['name']}  [进行中]")
        if t["goal"]:
            lines.append(f"    目标: {t['goal']}")
        if t["working_dir"]:
            lines.append(f"    目录: {t['working_dir']}")

    for t in failed:
        lines.append("")
        lines.append(f"  ✗ {t['name']}  [失败]")
        if t["goal"]:
            lines.append(f"    目标: {t['goal']}")
        lines.append(f"    原因: {t.get('failed_reason', '未知')}")

    if not has_tasks:
        lines.append("[任务]  无")
    else:
        lines.append("")

    lines.append(SEP)
    lines.append("")

    total_commits = sum(len(cs) for cs in repo_commits.values())
    active_repos = [r for r, cs in repo_commits.items() if cs]

    if active_repos:
        lines.append(f"[Git]  {total_commits} 个提交, 涉及 {len(active_repos)} 个仓库")

        for repo, commits in repo_commits.items():
            if not commits:
                continue
            lines.append("")
            lines.append(f"  {repo}  ({len(commits)} commits)")
            for c in commits:
                time_part = c["time"][-8:] if len(c["time"]) >= 8 else c["time"]
                diff_summary = ""
                if c["files"]:
                    diff_summary = f"  [修改 {len(c['files'])} 个文件]"
                lines.append(f"    {time_part}  {c['subject']}{diff_summary}")
    else:
        lines.append("[Git]  无提交")

    lines.append("")
    lines.append(SEP)
    lines.append("")

    lines.append(f"[摘要]  任务: {total_done} 完成, {total_pending} 进行中, {total_failed} 失败")
    lines.append(f"        提交: {total_commits} 个, 涉及 {len(active_repos)} 个仓库")

    lines.append("")
    return "\n".join(lines)


def main():
    date = parse_date(sys.argv[1] if len(sys.argv) > 1 else None)
    date_str = date.strftime("%Y-%m-%d")

    print(f"正在采集 {date_str} 的工作数据...")

    done, pending, failed = scan_tasks(date)

    repos = find_git_repos(PROJECTS_DIR)
    # 也扫 opencode 配置仓
    opencode_config = Path.home() / ".config" / "opencode"
    if opencode_config.is_dir() and (opencode_config / ".git").exists():
        repos.append(opencode_config)

    repo_commits = {}
    for repo in repos:
        commits = get_daily_commits(repo, date_str)
        repo_commits[str(repo)] = commits

    report = build_report(date, done, pending, failed, repo_commits)

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    output_path = OUTPUT_DIR / f"{date_str}.txt"
    output_path.write_text(report, encoding="utf-8")

    print(f"已保存到 {output_path}")


if __name__ == "__main__":
    main()
