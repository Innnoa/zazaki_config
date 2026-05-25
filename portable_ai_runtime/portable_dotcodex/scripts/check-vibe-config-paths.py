#!/usr/bin/env python3

from __future__ import annotations

import json
import re
import sys
from collections import Counter
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
VIBE_ROOT = ROOT / "skills" / "vibe"
CONFIG_ROOT = VIBE_ROOT / "config"

PLACEHOLDER_TOKENS = ("{run_id}", "{date}", "{slug}", "<run-id>", "<topic>", "YYYY-MM-DD")
STRING_RE = re.compile(r"^[A-Za-z0-9_./{}<>:-]+$")
LOCAL_REQUIRED_PREFIXES = (
    "config/",
    "scripts/",
    "protocols/",
    "templates/",
    "schemas/",
    "mcp/",
)
PROJECTION_ONLY_PREFIXES = (
    "skills/",
    "commands/",
    "bundled/skills/",
)
INSTALL_ONLY_HINT_KEYS = {
    "generated_compatibility",
    "allow_installed_only",
    "installed_runtime",
    "target_relpath",
    "receipt_relpath",
}
EXTERNAL_TOOLING_PREFIXES = (
    "docs/external-tooling/",
    "docs/governance/",
)
UPSTREAM_PROJECTION_PREFIXES = (
    "apps/",
    "packages/",
    "dist/",
    "adapters/",
)


def iter_strings(value, path: list[str]):
    if isinstance(value, dict):
        for key, child in value.items():
            yield from iter_strings(child, path + [str(key)])
        return
    if isinstance(value, list):
        for idx, child in enumerate(value):
            yield from iter_strings(child, path + [str(idx)])
        return
    if isinstance(value, str):
        yield path, value.strip()


def should_skip(raw: str) -> bool:
    if not raw:
        return True
    if "://" in raw or raw.startswith(("http", "$", "/")):
        return True
    if any(token in raw for token in PLACEHOLDER_TOKENS):
        return True
    if "/" not in raw:
        return True
    if not STRING_RE.match(raw):
        return True
    return False


def classify(path_keys: list[str], raw: str) -> str:
    joined = ".".join(path_keys)
    tail = path_keys[-1] if path_keys else ""

    if raw.startswith("outputs/"):
        return "runtime_generated"
    if any(token in raw for token in PLACEHOLDER_TOKENS):
        return "runtime_generated"
    if tail in {"store_relpath", "mock_response_path", "quarantine_root"}:
        return "runtime_generated"
    if raw.startswith((".tmp/", ".serena/")):
        return "runtime_generated"

    if any(key in joined for key in INSTALL_ONLY_HINT_KEYS):
        return "install_only"
    if raw.startswith("skills/vibe/"):
        return "install_only"
    if tail in {"host_profile", "settings_map", "closure", "manifest"}:
        return "install_only"
    if tail == "rel" and "default_target_root" in joined:
        return "install_only"

    if raw.startswith(PROJECTION_ONLY_PREFIXES):
        return "projection_only"
    if raw.startswith(UPSTREAM_PROJECTION_PREFIXES):
        return "projection_only"
    if tail in {"source_roles", "overlay_path", "write_scope", "specs_dir", "changes_dir", "directory"}:
        return "projection_only"
    if joined.endswith("materialization.promotion_stage"):
        return "projection_only"
    if raw in {"n/a", "CI/CD"}:
        return "projection_only"
    if raw.startswith(("engineering/", "design/", "product/", "marketing/", "project-management/", "testing/", "spatial-computing/", "openspec/", "tests/")):
        return "projection_only"

    if raw.startswith(EXTERNAL_TOOLING_PREFIXES):
        return "external_tooling"
    if raw.startswith("references/") and any(
        token in joined for token in ("evidence_artifacts", "packet_memo", "corpus_sources", "reviewed_packet")
    ):
        return "external_tooling"
    if tail in {"packet_memo", "admission_matrix_reference", "governance_reference", "contract_reference", "integration_reference", "conformance_doc", "memory_block_contract", "tool_rule_contract", "write_admission_contract"}:
        return "external_tooling"
    if joined.endswith("evaluation_hooks") or ".evaluation_hooks." in joined:
        return "external_tooling"
    if raw.startswith("references/") and not raw.startswith("references/changelog.md") and not raw.startswith("references/release-ledger.jsonl"):
        return "external_tooling"
    if "/" in raw and not raw.startswith(LOCAL_REQUIRED_PREFIXES) and not raw.startswith(("docs/requirements", "docs/plans")):
        return "external_tooling"

    if any(token in joined for token in ("optional", "optional_lockfiles")):
        return "optional_material"

    if raw.startswith(LOCAL_REQUIRED_PREFIXES):
        return "local_required"

    return "local_required"


def exists_for_class(category: str, raw: str) -> bool:
    if category in {"projection_only", "install_only", "external_tooling", "optional_material"}:
        return True
    if category == "runtime_generated":
        parent = VIBE_ROOT / raw
        return parent.parent.exists()
    return (VIBE_ROOT / raw).exists()


def main() -> int:
    errors: list[str] = []
    notes: list[str] = []
    counts: Counter[str] = Counter()

    for config_path in sorted(CONFIG_ROOT.glob("*.json")):
        data = json.loads(config_path.read_text(encoding="utf-8-sig"))
        for key_path, raw in iter_strings(data, []):
            if should_skip(raw):
                continue
            category = classify(key_path, raw)
            counts[category] += 1
            if exists_for_class(category, raw):
                continue
            label = f"{config_path.name}\t{'.'.join(key_path)}\t{category}\t{raw}"
            if category == "local_required":
                errors.append(label)
            else:
                notes.append(label)

    if errors:
        print("FAIL")
        for error in errors:
            print(f"- {error}")
        if notes:
            print("NOTES")
            for note in notes:
                print(f"- {note}")
        return 1

    summary = ", ".join(f"{key}={counts[key]}" for key in sorted(counts))
    print(f"PASS: vibe config path classification check ({summary})")
    if notes:
        print("NOTES")
        for note in notes:
            print(f"- {note}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
