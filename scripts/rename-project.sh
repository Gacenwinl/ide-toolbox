#!/usr/bin/env bash
# 在活动区内重命名项目目录并更新路径引用
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

OLD_NAME="${1:-}"
NEW_NAME="${2:-}"
[[ -n "$OLD_NAME" && -n "$NEW_NAME" ]] || die "用法: ./scripts/rename-project.sh OLD_NAME NEW_NAME"

ACTIVE_DIR="$(resolve_active_dir)"
SRC="${ACTIVE_DIR}/${OLD_NAME}"
DEST="${ACTIVE_DIR}/${NEW_NAME}"

[[ -d "$SRC" ]] || die "源目录不存在: $SRC"
[[ ! -e "$DEST" ]] || die "目标已存在: $DEST"

log "重命名: $SRC -> $DEST"
if ! confirm "确认重命名？"; then die "已取消"; fi

mv "$SRC" "$DEST"

patch_file() {
  local file="$1"
  [[ -f "$file" ]] || return 0
  if [[ "$(uname)" == "Darwin" ]]; then
    sed -i '' "s|${SRC}|${DEST}|g" "$file"
    sed -i '' "s|${OLD_NAME}|${NEW_NAME}|g" "$file"
  else
    sed -i "s|${SRC}|${DEST}|g" "$file"
    sed -i "s|${OLD_NAME}|${NEW_NAME}|g" "$file"
  fi
  log "已更新: $file"
}

while IFS= read -r -d '' f; do
  patch_file "$f"
done < <(find "$DEST" -type f \( -name '*.md' -o -name '*.mdc' \) -print0 2>/dev/null)

INDEX="${TOOLBOX_ROOT}/projects-index.md"
if [[ -f "$INDEX" ]]; then
  if [[ "$(uname)" == "Darwin" ]]; then
    sed -i '' "s|${SRC}|${DEST}|g" "$INDEX"
    sed -i '' "s|${OLD_NAME}|${NEW_NAME}|g" "$INDEX"
  else
    sed -i "s|${SRC}|${DEST}|g" "$INDEX"
    sed -i "s|${OLD_NAME}|${NEW_NAME}|g" "$INDEX"
  fi
  log "已更新 projects-index.md"
fi

log "完成: ${DEST}"
printf '\n下一步: ./ide "%s"\n' "$DEST"
