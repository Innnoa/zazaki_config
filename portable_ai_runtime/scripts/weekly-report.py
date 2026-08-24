#!/usr/bin/env python3
"""weekly-report — 聚合当前 ISO 周的日报生成周报。

用法: python3 weekly-report.py
输出: ~/docs/weekly/YYYY-Www.txt（如 2026-W33.txt）
"""

import sys
from datetime import date, timedelta
from pathlib import Path

DAILY_DIR = Path.home() / "docs" / "daily"
WEEKLY_DIR = Path.home() / "docs" / "weekly"

WEEKDAY_NAMES = ["周一", "周二", "周三", "周四", "周五", "周六", "周日"]

BANNER_SEP = "═" * 40


def main():
    today = date.today()
    iso_year, iso_week, _ = today.isocalendar()
    week_label = f"{iso_year}-W{iso_week:02d}"

    # 本周一与周日（ISO 周，周一起始）
    monday = today - timedelta(days=today.weekday())
    sunday = monday + timedelta(days=6)
    week_range = f"{monday.strftime('%m-%d')} ~ {sunday.strftime('%m-%d')}"

    # 收集本周的日报文件（按文件名解析日期，保持本周内的）
    present = {}
    if DAILY_DIR.is_dir():
        for f in sorted(DAILY_DIR.glob("*.txt")):
            try:
                d = date.fromisoformat(f.stem)
            except ValueError:
                continue
            if (d.isocalendar()[0], d.isocalendar()[1]) == (iso_year, iso_week):
                present[d] = f

    # 本周缺失的日期
    missing = []
    for i in range(7):
        d = monday + timedelta(days=i)
        if d not in present:
            missing.append(d)

    lines = []
    lines.append(BANNER_SEP)
    lines.append(f"周报 {week_label} ({week_range})")
    lines.append(BANNER_SEP)
    lines.append("")

    for d in sorted(present):
        lines.append(f"[{d.strftime('%Y-%m-%d')} {WEEKDAY_NAMES[d.weekday()]}]")
        lines.append(present[d].read_text(encoding="utf-8").rstrip("\n"))
        lines.append("")

    if missing:
        missing_str = " ".join(
            f"{d.strftime('%Y-%m-%d')} {WEEKDAY_NAMES[d.weekday()]}" for d in missing
        )
        lines.append(f"缺失日期: {missing_str}")

    WEEKLY_DIR.mkdir(parents=True, exist_ok=True)
    output_path = WEEKLY_DIR / f"{week_label}.txt"
    output_path.write_text("\n".join(lines).rstrip("\n") + "\n", encoding="utf-8")

    print(f"已保存到 {output_path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
