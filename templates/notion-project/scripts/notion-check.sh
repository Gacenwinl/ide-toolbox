#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

check() {
  if [[ -f "$1" ]]; then
    echo "[OK] $2"
  else
    echo "[WARN] 缺少 $2"
  fi
}

echo "Notion 项目检查: $(basename "$ROOT")"
check "$ROOT/manifest.yaml" "manifest.yaml"
check "$ROOT/NOTION_INDEX.md" "NOTION_INDEX.md"
check "$ROOT/docs/notion-sync-policy.md" "docs/notion-sync-policy.md"
check "$ROOT/docs/HANDOFF.md" "docs/HANDOFF.md"
check "$ROOT/data/tasks-master.csv" "data/tasks-master.csv"

if [[ -f "$ROOT/.env" ]]; then
  echo "[OK] .env 存在"
else
  echo "[WARN] 未配置 .env（如需 API 脚本，请复制 .env.example）"
fi

if grep -q 'notion_url: ""' "$ROOT/manifest.yaml" 2>/dev/null; then
  echo "[WARN] manifest.yaml 中仍有未填写的 notion_url"
fi
