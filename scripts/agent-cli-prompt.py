#!/usr/bin/env python3
"""Build prompts for ide-toolbox Agent CLI workflows."""

from __future__ import annotations

import argparse
from pathlib import Path


MAX_FILE_CHARS = 6000


def read_text(path: Path, *, limit: int = MAX_FILE_CHARS) -> str:
    if not path.is_file():
        return f"(missing: {path.name})"
    text = path.read_text(encoding="utf-8", errors="replace")
    if len(text) > limit:
        return text[:limit] + "\n\n...(truncated)..."
    return text


def collect_project_context(project_dir: Path, project_type: str) -> str:
    files = [
        "AGENTS.md",
        "docs/ai-context.md",
        "docs/agent-library.md",
    ]
    if project_type == "notion-sync":
        files.extend(
            [
                "docs/HANDOFF.md",
                "docs/notion-sync-policy.md",
                "manifest.yaml",
                "NOTION_INDEX.md",
            ]
        )
    else:
        files.extend(
            [
                "docs/runbook.md",
                "docs/conversation-reuse.md",
            ]
        )

    blocks: list[str] = []
    for rel in files:
        path = project_dir / rel
        blocks.append(f"## {rel}\n\n{read_text(path)}")
    return "\n\n---\n\n".join(blocks)


def render_template(template: str, replacements: dict[str, str]) -> str:
    for key, value in replacements.items():
        template = template.replace("{{" + key + "}}", value)
    return template


def main() -> int:
    parser = argparse.ArgumentParser(description="Build Agent CLI prompt")
    parser.add_argument("--template", required=True)
    parser.add_argument("--project", required=True)
    parser.add_argument("--context-dir", default="")
    parser.add_argument("--project-type", required=True)
    parser.add_argument("--privacy", required=True)
    parser.add_argument("--task", default="")
    parser.add_argument("--suggested-assets", default="")
    args = parser.parse_args()

    project_dir = Path(args.project).resolve()
    context_dir = Path(args.context_dir).resolve() if args.context_dir else project_dir
    template_path = Path(args.template)
    template = read_text(template_path, limit=12000)
    suggested_assets = (
        Path(args.suggested_assets).read_text(encoding="utf-8", errors="replace")
        if args.suggested_assets and Path(args.suggested_assets).is_file()
        else "(none)"
    )

    prompt = render_template(
        template,
        {
            "PROJECT_NAME": project_dir.name,
            "PROJECT_PATH": str(project_dir),
            "PROJECT_TYPE": args.project_type,
            "PRIVACY_PROFILE": args.privacy,
            "TASK": args.task or "接手项目并汇报当前状态",
            "PROJECT_CONTEXT": collect_project_context(context_dir, args.project_type),
            "SUGGESTED_ASSETS": suggested_assets,
        },
    )
    print(prompt)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
