#!/usr/bin/env bash
# 打印 Notion 导入提示。完整导入可结合 Cursor Notion MCP 或项目内批处理脚本。
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "项目: $(basename "$ROOT")"
echo "1. 先读 manifest.yaml 和 NOTION_INDEX.md"
echo "2. 使用 Cursor Notion MCP 或 notion_hygiene.py 进行导入/核查"
echo "3. 导入后更新 CHANGELOG.md 和 manifest.yaml 的 last_synced"

if [[ -f "$ROOT/manifest.yaml" ]]; then
  echo "--- manifest notion hub ---"
  grep -E 'hub_url|hub_title' "$ROOT/manifest.yaml" || true
fi
