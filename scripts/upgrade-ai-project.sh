#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

TARGET_DIR=""
PROJECT_NAME=""
PROJECT_TYPE="code"
PROJECT_PURPOSE="待补充项目目标"
YES=false
DRY_RUN=false

usage() {
  cat <<'EOF'
用法:
  ./scripts/upgrade-ai-project.sh /path/to/existing-project [options]

选项:
  --type code|docs|knowledge|automation
  --purpose "项目目标"
  --yes
  --dry-run

说明:
  为已有目录补齐 Cursor/Codex 多端模板文件，不覆盖已有文件。
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --type)
      PROJECT_TYPE="$2"
      shift 2
      ;;
    --purpose)
      PROJECT_PURPOSE="$2"
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
TEMPLATE_DIR="${TOOLBOX_ROOT}/templates/ai-project"

copy_if_missing() {
  local src="$1"
  local dest="$2"
  if [[ -e "$dest" ]]; then
    log "保留已有文件: $dest"
    return
  fi
  if [[ "$DRY_RUN" == "true" ]]; then
    log "[dry-run] 将创建: $dest"
    return
  fi
  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
  replace_placeholders "$dest" "$PROJECT_NAME" "$PROJECT_TYPE" "$PROJECT_PURPOSE"
  log "已创建: $dest"
}

log "升级项目: $TARGET_DIR"

copy_if_missing "${TEMPLATE_DIR}/AGENTS.md" "${TARGET_DIR}/AGENTS.md"
copy_if_missing "${TEMPLATE_DIR}/README.md" "${TARGET_DIR}/README.md"
copy_if_missing "${TEMPLATE_DIR}/docs/ai-context.md" "${TARGET_DIR}/docs/ai-context.md"
copy_if_missing "${TEMPLATE_DIR}/docs/runbook.md" "${TARGET_DIR}/docs/runbook.md"
copy_if_missing "${TEMPLATE_DIR}/docs/conversation-reuse.md" "${TARGET_DIR}/docs/conversation-reuse.md"
copy_if_missing "${TEMPLATE_DIR}/docs/devices.md" "${TARGET_DIR}/docs/devices.md"
copy_if_missing "${TEMPLATE_DIR}/.cursor/rules/ai-agent-workflow.mdc" "${TARGET_DIR}/.cursor/rules/ai-agent-workflow.mdc"
copy_if_missing "${TEMPLATE_DIR}/.gitignore" "${TARGET_DIR}/.gitignore"

if [[ "$DRY_RUN" == "true" ]]; then
  exit 0
fi

if [[ ! -d "${TARGET_DIR}/.git" && "${YES:-false}" != "true" ]]; then
  if confirm "该项目尚未初始化 Git，是否现在初始化？"; then
    require_command git
    (
      cd "$TARGET_DIR"
      git init -q
      git add .
      log "已初始化 Git，但未自动 commit"
    )
  fi
fi

check_sensitive_files "$TARGET_DIR"
append_project_index "$PROJECT_NAME" "$TARGET_DIR" "$PROJECT_TYPE" "unchanged" "upgraded"

cat <<EOF

项目已升级:
  路径: ${TARGET_DIR}

说明:
  - 已有文件未被覆盖
  - 未自动 commit，请先检查变更

建议 commit message:
  docs: add AI agent workflow scaffold
EOF
