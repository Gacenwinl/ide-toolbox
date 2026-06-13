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
agent_hook_candidates=()

while IFS= read -r -d '' dir; do
  name="$(basename "$dir")"
  [[ "$name" == "ide-toolbox" ]] && continue
  if project_missing_scaffold "$dir"; then
    candidates+=("$dir")
  fi
  if project_missing_agent_library_hook "$dir"; then
    agent_hook_candidates+=("$dir")
  fi
done < <(find "$ACTIVE_DIR" -mindepth 1 -maxdepth 1 -type d -print0)

printf '\n扫描目录: %s\n' "$ACTIVE_DIR"
printf '候选升级项目（缺 AGENTS/runbook）: %d\n' "${#candidates[@]}"
printf '缺少 agent-library 挂钩: %d\n\n' "${#agent_hook_candidates[@]}"

if [[ "${#candidates[@]}" -eq 0 && "${#agent_hook_candidates[@]}" -eq 0 ]]; then
  log "没有发现缺少 AGENTS.md、docs/runbook.md 或 agent-library 挂钩的项目"
  exit 0
fi

if [[ "${#candidates[@]}" -gt 0 ]]; then
  for dir in "${candidates[@]}"; do
    printf '  [scaffold] %s\n' "$dir"
  done
fi

if [[ "${#agent_hook_candidates[@]}" -gt 0 ]]; then
  for dir in "${agent_hook_candidates[@]}"; do
    printf '  [agent-library] %s\n' "$dir"
  done
fi

if [[ "${#candidates[@]}" -eq 0 ]]; then
  printf '\n[dry-run] 仅缺 agent-library 挂钩。执行 upgrade-ai-project.sh --execute 可补齐。\n'
  if [[ "$EXECUTE" != "true" ]]; then
    exit 0
  fi
  for dir in "${agent_hook_candidates[@]}"; do
    log "补齐 agent-library: $dir"
    YES=true "${SCRIPT_DIR}/upgrade-ai-project.sh" "$dir" || warn "升级失败: $dir"
  done
  log "agent-library 挂钩补齐完成"
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
