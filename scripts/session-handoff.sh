#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

TARGET_DIR=""
SUMMARY=""
RUN_CAPTURE=false
DRY_RUN=false

usage() {
  cat <<'EOF'
用法:
  ./scripts/session-handoff.sh /path/to/project [options]

选项:
  --summary "上次会话摘要"
  --capture          同时生成 capture-conversation 模板
  --dry-run
  -h, --help

说明:
  检查并提示更新 docs/ai-context.md（Current State / Last Session），
  确保下一 Agent 无需依赖聊天记录即可接手。
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --summary) SUMMARY="$2"; shift 2 ;;
    --capture) RUN_CAPTURE=true; shift ;;
    --dry-run) DRY_RUN=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *)
      if [[ -z "$TARGET_DIR" ]]; then
        TARGET_DIR="$1"
        shift
      else
        die "未知参数: $1"
      fi
      ;;
  esac
done

[[ -n "$TARGET_DIR" ]] || { usage; die "缺少项目路径"; }
[[ -d "$TARGET_DIR" ]] || die "目录不存在: $TARGET_DIR"

AI_CONTEXT="${TARGET_DIR}/docs/ai-context.md"
[[ -f "$AI_CONTEXT" ]] || die "缺少 docs/ai-context.md，请先 upgrade-ai-project.sh"

PROJECT_NAME="$(basename "$TARGET_DIR")"
TODAY="$(date +%Y-%m-%d)"
WARN_COUNT=0
OK_COUNT=0

handoff_ok() { printf '[OK] %s\n' "$1"; OK_COUNT=$((OK_COUNT + 1)); }
handoff_warn() { printf '[WARN] %s\n' "$1"; WARN_COUNT=$((WARN_COUNT + 1)); }

printf '\n========================================\n'
printf ' 会话收尾移交: %s\n' "$PROJECT_NAME"
printf '========================================\n\n'

if grep -q "待填写" "$AI_CONTEXT" 2>/dev/null; then
  handoff_warn "ai-context.md 仍含「待填写」——下一 Agent 无法仅靠文件接手"
else
  handoff_ok "ai-context.md 无「待填写」占位"
fi

if grep -A1 "## Last Session" "$AI_CONTEXT" 2>/dev/null | grep -q "(none yet)"; then
  handoff_warn "Last Session 日期仍为 (none yet)"
else
  handoff_ok "Last Session 已有日期记录"
fi

if [[ -f "${TARGET_DIR}/docs/suggested-assets.md" ]]; then
  handoff_ok "存在 docs/suggested-assets.md"
elif [[ -f "${TARGET_DIR}/docs/agent-library.md" ]] \
  && grep -q "Privacy Profile: \`private-local\`" "${TARGET_DIR}/docs/agent-library.md" 2>/dev/null; then
  handoff_ok "private-local：已正确跳过 suggested-assets"
elif is_toolbox_project "$TARGET_DIR"; then
  handoff_ok "工具箱项目无 suggested-assets（预期）"
else
  handoff_warn "缺少 docs/suggested-assets.md（可 upgrade 或 new-ai-project 挂钩）"
fi

if [[ "$DRY_RUN" == "true" ]]; then
  log "[dry-run] 未修改文件"
  exit 0
fi

if [[ -n "$SUMMARY" ]]; then
  safe_summary="${SUMMARY//\\/\\\\}"
  safe_summary="${safe_summary//|/\\|}"
  if [[ "$(uname)" == "Darwin" ]]; then
    sed -i '' "s/^- Date: .*/- Date: ${TODAY}/" "$AI_CONTEXT"
    sed -i '' "s|^- Summary: .*|- Summary: ${safe_summary}|" "$AI_CONTEXT"
  else
    sed -i "s/^- Date: .*/- Date: ${TODAY}/" "$AI_CONTEXT"
    sed -i "s|^- Summary: .*|- Summary: ${safe_summary}|" "$AI_CONTEXT"
  fi
  handoff_ok "已写入 Last Session 摘要"
elif grep -q "^- Date: (none yet)" "$AI_CONTEXT" 2>/dev/null; then
  if [[ "$(uname)" == "Darwin" ]]; then
    sed -i '' "s/^- Date: (none yet)/- Date: ${TODAY}/" "$AI_CONTEXT"
  else
    sed -i "s/^- Date: (none yet)/- Date: ${TODAY}/" "$AI_CONTEXT"
  fi
  handoff_warn "已更新 Last Session 日期，但 Summary 仍需手动填写或使用 --summary"
fi

if [[ "$RUN_CAPTURE" == "true" ]]; then
  "${SCRIPT_DIR}/capture-conversation.sh" "$TARGET_DIR" --title "session-handoff"
  handoff_ok "已生成 capture 文档"
fi

printf '\n--- 会话结束清单 ---\n'
printf '1. 更新 docs/ai-context.md → Current State / Last Session / Recent Decisions\n'
printf '2. 重要对话 → capture-conversation.sh 或 conversation-reuse.md\n'
printf '3. 中文说明：改动、验证、回滚、建议 commit message\n'
printf '4. 可复用且跨项目 → promote-agent-asset.sh（非 private-local）\n'

printf '\n总结: OK=%d, WARN=%d\n' "$OK_COUNT" "$WARN_COUNT"
if [[ "$WARN_COUNT" -gt 0 ]]; then
  printf '移交未就绪：请处理 WARN 后再结束会话。\n'
  exit 1
fi
printf '移交检查通过。\n'
