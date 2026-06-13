#!/usr/bin/env python3
"""Agent Library manifest helpers (stdlib only)."""

from __future__ import annotations

import argparse
import json
import re
import sys
from datetime import date
from pathlib import Path
from typing import Any


def _strip_quotes(value: str) -> str:
    value = value.strip()
    if (value.startswith('"') and value.endswith('"')) or (
        value.startswith("'") and value.endswith("'")
    ):
        return value[1:-1]
    return value


def _parse_inline_list(value: str) -> list[str]:
    value = value.strip()
    if not value.startswith("[") or not value.endswith("]"):
        return [_strip_quotes(value)] if value else []
    inner = value[1:-1].strip()
    if not inner:
        return []
    parts = re.split(r",\s*", inner)
    return [_strip_quotes(p) for p in parts if p.strip()]


def load_entries(manifest_path: Path) -> list[dict[str, Any]]:
    if not manifest_path.is_file():
        return []
    text = manifest_path.read_text(encoding="utf-8")
    entries: list[dict[str, Any]] = []
    current: dict[str, Any] | None = None
    in_entries = False

    for raw_line in text.splitlines():
        line = raw_line.rstrip()
        stripped = line.strip()
        if stripped == "entries:" or stripped.startswith("entries:"):
            in_entries = True
            continue
        if in_entries and stripped and not stripped.startswith("-") and not line.startswith("  "):
            break
        if not in_entries:
            continue
        if stripped.startswith("- id:"):
            if current:
                entries.append(current)
            current = {"id": _strip_quotes(stripped.split(":", 1)[1].strip())}
            continue
        if current is None:
            continue
        if ":" not in stripped:
            continue
        key, value = stripped.split(":", 1)
        key = key.strip()
        value = value.strip()
        if key in ("tags", "triggers", "project_types"):
            current[key] = _parse_inline_list(value)
        else:
            current[key] = _strip_quotes(value)

    if current:
        entries.append(current)
    return entries


def _tokenize(text: str) -> list[str]:
    text = text.lower()
    tokens = re.findall(r"[a-z0-9\u4e00-\u9fff]+", text)
    return [t for t in tokens if len(t) >= 2]


def score_entry(
    entry: dict[str, Any],
    *,
    task: str,
    purpose: str,
    project_type: str,
    privacy: str,
) -> int:
    if privacy == "private-local":
        return 0
    if entry.get("privacy") == "private-local":
        return 0

    score = 0
    types = entry.get("project_types") or []
    if project_type and types and project_type in types:
        score += 3

    haystack = " ".join(
        [
            task,
            purpose,
            str(entry.get("title", "")),
            str(entry.get("when_to_use", "")),
            " ".join(entry.get("tags") or []),
            " ".join(entry.get("triggers") or []),
        ]
    ).lower()
    tokens = set(_tokenize(task) + _tokenize(purpose))
    for trigger in entry.get("triggers") or []:
        if trigger.lower() in haystack and trigger.lower() in tokens:
            score += 5
        elif trigger.lower() in haystack:
            score += 2
    for tag in entry.get("tags") or []:
        if tag.lower() in tokens:
            score += 2
    return score


def query_entries(
    manifest_path: Path,
    *,
    task: str = "",
    purpose: str = "",
    project_type: str = "",
    privacy: str = "code",
    min_score: int = 2,
) -> list[dict[str, Any]]:
    if privacy == "private-local":
        return []
    ranked: list[tuple[int, dict[str, Any]]] = []
    for entry in load_entries(manifest_path):
        score = score_entry(
            entry,
            task=task,
            purpose=purpose,
            project_type=project_type,
            privacy=privacy,
        )
        if score >= min_score:
            ranked.append((score, entry))
    ranked.sort(key=lambda item: item[0], reverse=True)
    return [entry for _, entry in ranked]


def format_markdown(
    matches: list[dict[str, Any]],
    *,
    library_dir: Path,
    task: str,
    purpose: str,
    project_type: str,
    privacy: str,
) -> str:
    lines = [
        "# Suggested Agent Library Assets",
        "",
        f"- Generated: {date.today().isoformat()}",
        f"- Library: `{library_dir}`",
        f"- Project type: `{project_type}`",
        f"- Privacy: `{privacy}`",
    ]
    if purpose:
        lines.append(f"- Purpose: {purpose}")
    if task:
        lines.append(f"- Task hint: {task}")
    lines.append("")

    if privacy == "private-local":
        lines.extend(
            [
                "本项目为 `private-local`，已跳过共享 Agent Library。",
                "",
                "仅使用项目内 `docs/` 文件，禁止读取 `05_Agent-Library`。",
            ]
        )
        return "\n".join(lines) + "\n"

    if not matches:
        lines.extend(
            [
                "当前 manifest 无高置信匹配条目。",
                "",
                "会话启动仍请阅读 `docs/agent-library.md`。任务前可运行：",
                "",
                "```bash",
                "./scripts/query-agent-assets.sh --task \"<任务摘要>\"",
                "```",
            ]
        )
        return "\n".join(lines) + "\n"

    lines.append("## 推荐阅读顺序")
    lines.append("")
    for idx, entry in enumerate(matches, start=1):
        rel = entry.get("path", "")
        abs_path = library_dir / rel if rel else library_dir
        lines.append(f"{idx}. **{entry.get('title', entry.get('id', 'asset'))}** (`{entry.get('id', '')}`)")
        lines.append(f"   - Path: `{abs_path}`")
        if entry.get("when_to_use"):
            lines.append(f"   - When: {entry['when_to_use']}")
        if entry.get("when_not_to_use"):
            lines.append(f"   - Avoid: {entry['when_not_to_use']}")
        lines.append("")
    return "\n".join(lines) + "\n"


def append_entry_block(manifest_path: Path, entry: dict[str, Any]) -> None:
    text = manifest_path.read_text(encoding="utf-8") if manifest_path.is_file() else ""
    if "entries:" not in text:
        text = text.rstrip() + "\n\nentries: []\n"
    if re.search(rf"^\s*-\s*id:\s*{re.escape(entry['id'])}\s*$", text, re.M):
        raise SystemExit(f"manifest 已存在 id: {entry['id']}")

    block_lines = [
        f"  - id: {entry['id']}",
        f"    title: {json.dumps(entry.get('title', entry['id']), ensure_ascii=False)}",
        f"    type: {entry.get('type', 'playbook')}",
        f"    path: {entry.get('path', '')}",
        f"    privacy: {entry.get('privacy', 'automation')}",
    ]
    tags = entry.get("tags") or []
    triggers = entry.get("triggers") or []
    project_types = entry.get("project_types") or []
    block_lines.append(
        "    tags: [" + ", ".join(json.dumps(t, ensure_ascii=False) for t in tags) + "]"
    )
    block_lines.append(
        "    triggers: ["
        + ", ".join(json.dumps(t, ensure_ascii=False) for t in triggers)
        + "]"
    )
    block_lines.append(
        "    project_types: ["
        + ", ".join(json.dumps(t, ensure_ascii=False) for t in project_types)
        + "]"
    )
    for key in ("when_to_use", "when_not_to_use", "source_project", "last_verified", "version"):
        if entry.get(key):
            block_lines.append(
                f"    {key}: {json.dumps(str(entry[key]), ensure_ascii=False)}"
            )
    block = "\n".join(block_lines)

    if re.search(r"^entries:\s*\[\s*\]\s*$", text, re.M):
        text = re.sub(r"^entries:\s*\[\s*\]\s*$", "entries:\n" + block, text, count=1, flags=re.M)
    elif "entries:" in text:
        text = text.rstrip() + "\n" + block + "\n"
    else:
        text = text.rstrip() + "\n\nentries:\n" + block + "\n"

    manifest_path.write_text(text, encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description="Agent Library manifest helper")
    sub = parser.add_subparsers(dest="cmd", required=True)

    q = sub.add_parser("query")
    q.add_argument("--manifest", required=True)
    q.add_argument("--library-dir", required=True)
    q.add_argument("--task", default="")
    q.add_argument("--purpose", default="")
    q.add_argument("--type", default="")
    q.add_argument("--privacy", default="code")
    q.add_argument("--format", choices=["markdown", "json"], default="markdown")
    q.add_argument("--min-score", type=int, default=2)

    a = sub.add_parser("append")
    a.add_argument("--manifest", required=True)
    a.add_argument("--id", required=True)
    a.add_argument("--title", required=True)
    a.add_argument("--type", default="playbook")
    a.add_argument("--path", required=True)
    a.add_argument("--privacy", default="automation")
    a.add_argument("--tags", default="")
    a.add_argument("--triggers", default="")
    a.add_argument("--project-types", default="")
    a.add_argument("--when-to-use", default="")
    a.add_argument("--when-not-to-use", default="")
    a.add_argument("--source-project", default="")
    a.add_argument("--version", default="1.0")

    args = parser.parse_args()
    manifest = Path(args.manifest)

    if args.cmd == "query":
        matches = query_entries(
            manifest,
            task=args.task,
            purpose=args.purpose,
            project_type=args.type,
            privacy=args.privacy,
            min_score=args.min_score,
        )
        if args.format == "json":
            print(json.dumps(matches, ensure_ascii=False, indent=2))
        else:
            print(
                format_markdown(
                    matches,
                    library_dir=Path(args.library_dir),
                    task=args.task,
                    purpose=args.purpose,
                    project_type=args.type,
                    privacy=args.privacy,
                ),
                end="",
            )
        return 0

    entry = {
        "id": args.id,
        "title": args.title,
        "type": args.type,
        "path": args.path,
        "privacy": args.privacy,
        "tags": [t.strip() for t in args.tags.split(",") if t.strip()],
        "triggers": [t.strip() for t in args.triggers.split(",") if t.strip()],
        "project_types": [t.strip() for t in args.project_types.split(",") if t.strip()],
        "when_to_use": args.when_to_use,
        "when_not_to_use": args.when_not_to_use,
        "source_project": args.source_project,
        "last_verified": date.today().isoformat(),
        "version": args.version,
    }
    append_entry_block(manifest, entry)
    return 0


if __name__ == "__main__":
    sys.exit(main())
