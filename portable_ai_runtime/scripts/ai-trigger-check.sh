#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CASES_FILE="$ROOT_DIR/references/ai/trigger-check-cases.tsv"

python3 - "$ROOT_DIR" "$CASES_FILE" <<'PY'
from pathlib import Path
import csv
import sys

root = Path(sys.argv[1])
cases_file = Path(sys.argv[2])
errors = []
checked = 0

with cases_file.open(encoding="utf-8", newline="") as fh:
    reader = csv.DictReader(fh, delimiter="\t")
    required_columns = {"phrase", "expected_route", "expected_anchor_file", "expected_anchor_text", "note"}
    if set(reader.fieldnames or []) != required_columns:
        print("FAIL")
        print(f"- invalid header: {reader.fieldnames}")
        sys.exit(1)

    trigger_phrases = (root / "references" / "ai" / "trigger-phrases.md").read_text(encoding="utf-8")
    routing_rules = (root / "rules" / "ai" / "routing-rules.md").read_text(encoding="utf-8")
    agents = (root / "AGENTS.md").read_text(encoding="utf-8")

    for row in reader:
        checked += 1
        phrase = row["phrase"].strip()
        expected_route = row["expected_route"].strip()
        expected_file = root / row["expected_anchor_file"].strip()
        expected_anchor_text = row["expected_anchor_text"].strip()
        note = row["note"].strip()
        if phrase not in trigger_phrases:
            errors.append(f"phrase not found in trigger-phrases.md: {phrase} ({note})")
        if expected_route not in trigger_phrases and expected_route not in routing_rules and expected_route not in agents:
            errors.append(f"route not anchored in rules or shell: {expected_route} ({note})")
        if not expected_file.exists():
            errors.append(f"missing expected file for phrase '{phrase}': {expected_file.relative_to(root)} ({note})")
            continue
        content = expected_file.read_text(encoding="utf-8")
        if expected_anchor_text not in content:
            errors.append(f"anchor text not found in {expected_file.relative_to(root)}: {expected_anchor_text} ({note})")

if checked == 0:
    errors.append("no trigger cases loaded")

if errors:
    print("FAIL")
    for error in errors:
        print(f"- {error}")
    sys.exit(1)

print(f"PASS: {checked} trigger cases")
PY
