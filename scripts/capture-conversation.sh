#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

TARGET_DIR=""
TITLE=""
YES=false
DRY_RUN=false

usage() {
  cat <<'EOF'
用法:
  ./scripts/capture-conversation.sh /path/to/project [--title "标题"] [--dry-run]

说明:
  在项目 docs/ 下生成一份对话复用记录模板，便于把重要讨论沉淀为项目记忆。
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --title)
      TITLE="$2"
      shift 2
      ;;
    --yes)
      YES=true
      shift
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
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

PROJECT_NAME="$(basename "$TARGET_DIR")"
DATE_TAG="$(date +%Y%m%d-%H%M%S)"
SAFE_TITLE="${TITLE:-conversation-capture}"
SAFE_TITLE="$(echo "$SAFE_TITLE" | tr ' /' '--' | tr -cd '[:alnum:]-_')"
OUTPUT_FILE="${TARGET_DIR}/docs/${DATE_TAG}-${SAFE_TITLE}.md"

if [[ "$DRY_RUN" == "true" ]]; then
  log "[dry-run] 将创建: $OUTPUT_FILE"
  exit 0
fi

mkdir -p "${TARGET_DIR}/docs"

cat > "$OUTPUT_FILE" <<'EOF'
# Conversation Capture — PROJECT_NAME_PLACEHOLDER

Captured at: TIMESTAMP_PLACEHOLDER

## Goal

What problem did this conversation solve?

## Constraints

What user rules, tools, paths, or habits shaped the solution?

## Decision Logic

What rule should future agents apply when facing the same kind of problem?

## Project-Level Memory

Which project files should be updated?

## User-Level Memory Candidate

Which preferences should be promoted to Cursor/Codex user rules or skills?

## Verification

How can the next agent check that the handoff is usable?

## Rollback

How can the user undo the changes?

## Suggested Commit Message

docs: capture reusable conversation logic

## Agent Library Promotion Review

- Is this output useful in a **second different project**?
- Have paths, secrets, and ID document details been removed?
- If yes → run ide-toolbox promote-agent-asset.sh or ./ide promote menu
- If no → keep only in this project's docs/
- private-local projects must **never** promote to 05_Agent-Library

## Session Handoff

- Sync docs/ai-context.md: Current State, Last Session, Recent Decisions
- Run: ./scripts/session-handoff.sh TARGET_DIR_PLACEHOLDER
EOF

if [[ "$(uname)" == "Darwin" ]]; then
  sed -i '' "s/PROJECT_NAME_PLACEHOLDER/${PROJECT_NAME//\//\\/}/g" "$OUTPUT_FILE"
  sed -i '' "s/TIMESTAMP_PLACEHOLDER/$(date '+%Y-%m-%d %H:%M:%S')/g" "$OUTPUT_FILE"
  sed -i '' "s|TARGET_DIR_PLACEHOLDER|${TARGET_DIR//\//\\/}|g" "$OUTPUT_FILE"
else
  sed -i "s/PROJECT_NAME_PLACEHOLDER/${PROJECT_NAME//\//\\/}/g" "$OUTPUT_FILE"
  sed -i "s/TIMESTAMP_PLACEHOLDER/$(date '+%Y-%m-%d %H:%M:%S')/g" "$OUTPUT_FILE"
  sed -i "s|TARGET_DIR_PLACEHOLDER|${TARGET_DIR//\//\\/}|g" "$OUTPUT_FILE"
fi

log "已创建对话复用记录: $OUTPUT_FILE"
log "请把本次重要结论补充进该文件，并同步 docs/ai-context.md（Current State / Last Session）"
log "收尾检查: ./scripts/session-handoff.sh \"$TARGET_DIR\""
