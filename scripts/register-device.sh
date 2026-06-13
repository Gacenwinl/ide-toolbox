#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

TARGET_DIR=""
DRY_RUN=false
NOTE=""

usage() {
  cat <<'EOF'
用法:
  ./scripts/register-device.sh /path/to/project [--note "备注"] [--dry-run]
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --note) NOTE="$2"; shift 2 ;;
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

DEVICE_NAME="$(current_device_name)"
PROJECT_NAME="$(basename "$TARGET_DIR")"
DEVICES_FILE="${TARGET_DIR}/docs/devices.md"
TEMPLATE_FILE="${TOOLBOX_ROOT}/templates/ai-project/docs/devices.md"
NOW="$(date '+%Y-%m-%d %H:%M')"
NOTE="${NOTE:-}"

if [[ "$DRY_RUN" == "true" ]]; then
  log "[dry-run] 将登记设备 ${DEVICE_NAME} 到 ${DEVICES_FILE}"
  exit 0
fi

mkdir -p "${TARGET_DIR}/docs"

if [[ ! -f "$DEVICES_FILE" ]]; then
  cp "$TEMPLATE_FILE" "$DEVICES_FILE"
  replace_placeholders "$DEVICES_FILE" "$PROJECT_NAME" "unknown" "待补充项目目标" "code"
  sed -i.bak '/| _示例_ |/d' "$DEVICES_FILE" 2>/dev/null || sed -i '/| _示例_ |/d' "$DEVICES_FILE"
  rm -f "${DEVICES_FILE}.bak"
fi

if grep -q "| ${DEVICE_NAME} |" "$DEVICES_FILE"; then
  if [[ "$(uname)" == "Darwin" ]]; then
    sed -i '' "s|^| ${DEVICE_NAME} |.*|${DEVICE_NAME} | ${TARGET_DIR} | ${NOW} | ${NOTE:-已更新} |" "$DEVICES_FILE"
  else
    sed -i "s|^| ${DEVICE_NAME} |.*|${DEVICE_NAME} | ${TARGET_DIR} | ${NOW} | ${NOTE:-已更新} |" "$DEVICES_FILE"
  fi
  log "已更新设备登记: ${DEVICE_NAME}"
else
  printf '| %s | %s | %s | %s |\n' "$DEVICE_NAME" "$TARGET_DIR" "$NOW" "${NOTE:-首次登记}" >> "$DEVICES_FILE"
  log "已新增设备登记: ${DEVICE_NAME}"
fi

log "设备台账: $DEVICES_FILE"
