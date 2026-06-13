#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

EXECUTE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --execute) EXECUTE=true; shift ;;
    --dry-run) EXECUTE=false; shift ;;
    -h|--help)
      echo "用法: ./scripts/batch-upgrade.sh [--execute]"
      exit 0
      ;;
    *) die "未知参数: $1" ;;
  esac
done

ACTIVE_DIR="$(resolve_active_dir)"
candidates=()

while IFS= read -r -d '' dir; do
  name="$(basename "$dir")"
  [[ "$name" == "ide-toolbox" ]] && continue
  if project_missing_scaffold "$dir"; then
    candidates+=("$dir")
  fi
done < <(find "$ACTIVE_DIR" -mindepth 1 -maxdepth 1 -type d -print0)

printf '\n扫描目录: %s\n' "$ACTIVE_DIR"
printf '候选升级项目: %d\n\n' "${#candidates[@]}"

if [[ "${#candidates[@]}" -eq 0 ]]; then
  log "没有发现缺少 AGENTS.md 或 docs/runbook.md 的项目"
  exit 0
fi

for dir in "${candidates[@]}"; do
  printf '  - %s\n' "$dir"
done

if [[ "$EXECUTE" != "true" ]]; then
  printf '\n[dry-run] 未执行升级。如需真正执行，请加 --execute\n'
  exit 0
fi

if ! confirm "确认批量升级以上 ${#candidates[@]} 个项目？"; then
  log "已取消"
  exit 0
fi

for dir in "${candidates[@]}"; do
  log "升级: $dir"
  YES=true "${SCRIPT_DIR}/upgrade-ai-project.sh" "$dir" || warn "升级失败: $dir"
done

log "批量升级完成。请逐个检查变更，未自动 commit。"
