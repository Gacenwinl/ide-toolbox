#!/usr/bin/env python3
"""轻量 Notion 项目核查脚本。完整批处理可按项目需要扩展。"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
REQUIRED = [
    ROOT / "manifest.yaml",
    ROOT / "NOTION_INDEX.md",
    ROOT / "docs" / "notion-sync-policy.md",
    ROOT / "docs" / "HANDOFF.md",
    ROOT / "data" / "tasks-master.csv",
]


def cmd_verify() -> int:
    missing = [p for p in REQUIRED if not p.exists()]
    if missing:
        print("[WARN] 缺少文件:")
        for p in missing:
            print(f"  - {p.relative_to(ROOT)}")
        return 1
    manifest = (ROOT / "manifest.yaml").read_text(encoding="utf-8")
    if 'notion_url: ""' in manifest:
        print("[WARN] manifest.yaml 中仍有未填写的 notion_url")
        return 1
    print("[OK] Notion 项目骨架完整")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="Notion project hygiene checks")
    sub = parser.add_subparsers(dest="command", required=True)
    sub.add_parser("verify", help="检查本地骨架是否齐全")
    args = parser.parse_args()
    if args.command == "verify":
        return cmd_verify()
    return 0


if __name__ == "__main__":
    sys.exit(main())
