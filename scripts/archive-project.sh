#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

TARGET_DIR=""
YES=false
DRY_RUN=true

usage() {
  cat <<'EOF'
用法:
  ./scripts/archive-project.sh /path/to/project [options]

选项:
  --execute     真正执行移动（默认仅 dry-run）
  --yes         跳过确认

说明:
  默认只展示归档计划，不移动目录。
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --execute)
      DRY_RUN=false
      shift
      ;;
    --yes)
      YES=true
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
ARCHIVE_ROOT="$(resolve_archive_dir)"
ARCHIVE_SUBDIR="$(read_policy_value "archive_subdir" "99_归档")"
DEST_DIR="${ARCHIVE_ROOT}/${ARCHIVE_SUBDIR}/${PROJECT_NAME}"

log "源目录: $TARGET_DIR"
log "目标目录: $DEST_DIR"

if [[ -e "$DEST_DIR" ]]; then
  die "归档目标已存在: $DEST_DIR"
fi

if [[ "$DRY_RUN" == "true" ]]; then
  log "[dry-run] 将把项目移动到: $DEST_DIR"
  log "如需真正执行，请加 --execute"
  exit 0
fi

if ! confirm "确认将项目归档到 ${DEST_DIR} 吗？"; then
  log "已取消归档"
  exit 0
fi

mkdir -p "$(dirname "$DEST_DIR")"
mv "$TARGET_DIR" "$DEST_DIR"
append_project_index "$PROJECT_NAME" "$DEST_DIR" "unknown" "unchanged" "archived"

log "项目已归档到: $DEST_DIR"
log "建议手动更新 projects-index.md 中的状态和备注"
