#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

SOURCE_FILE=""
PROJECT_DIR=""
ASSET_ID=""
TITLE=""
ASSET_TYPE="playbook"
TAGS=""
TRIGGERS=""
PROJECT_TYPES=""
WHEN_TO_USE=""
WHEN_NOT_TO_USE=""
PRIVACY="automation"
DRY_RUN=false
YES=false

usage() {
  cat <<'EOF'
用法:
  ./scripts/promote-agent-asset.sh --project /path/to/project --source /path/to/file \
    --id asset-id --title "标题" [options]

选项:
  --type skill|playbook|template
  --tags "tag1,tag2"
  --triggers "词1,词2"
  --project-types "code,knowledge"
  --when-to-use "说明"
  --when-not-to-use "说明"
  --privacy automation|knowledge
  --dry-run
  --yes
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) PROJECT_DIR="$2"; shift 2 ;;
    --source) SOURCE_FILE="$2"; shift 2 ;;
    --id) ASSET_ID="$2"; shift 2 ;;
    --title) TITLE="$2"; shift 2 ;;
    --type) ASSET_TYPE="$2"; shift 2 ;;
    --tags) TAGS="$2"; shift 2 ;;
    --triggers) TRIGGERS="$2"; shift 2 ;;
    --project-types) PROJECT_TYPES="$2"; shift 2 ;;
    --when-to-use) WHEN_TO_USE="$2"; shift 2 ;;
    --when-not-to-use) WHEN_NOT_TO_USE="$2"; shift 2 ;;
    --privacy) PRIVACY="$2"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    --yes) YES=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) die "未知参数: $1" ;;
  esac
done

[[ -n "$SOURCE_FILE" && -f "$SOURCE_FILE" ]] || { usage; die "缺少或无效 --source 文件"; }
[[ -n "$ASSET_ID" ]] || die "缺少 --id"
[[ -n "$TITLE" ]] || die "缺少 --title"

if [[ -n "$PROJECT_DIR" && -f "${PROJECT_DIR}/docs/agent-library.md" ]]; then
  if grep -q "private-local" "${PROJECT_DIR}/docs/agent-library.md" 2>/dev/null \
    && grep -q "禁止读 05" "${PROJECT_DIR}/docs/agent-library.md" 2>/dev/null; then
    die "private-local 项目禁止晋升到 Agent Library"
  fi
fi

LIB_DIR="$(resolve_agent_library_dir)"
MANIFEST_NAME="$(read_agent_library_policy_value manifest "manifest.yaml")"
MANIFEST_PATH="${LIB_DIR}/${MANIFEST_NAME}"
PY="${SCRIPT_DIR}/agent-library.py"

case "$ASSET_TYPE" in
  skill) DEST_SUBDIR="skills" ;;
  template) DEST_SUBDIR="templates" ;;
  *) DEST_SUBDIR="playbooks" ;;
esac

DEST_DIR="${LIB_DIR}/${DEST_SUBDIR}"
DEST_FILE="${DEST_DIR}/$(basename "$SOURCE_FILE")"
REL_PATH="${DEST_SUBDIR}/$(basename "$SOURCE_FILE")"
SOURCE_PROJECT=""
[[ -n "$PROJECT_DIR" ]] && SOURCE_PROJECT="$(basename "$PROJECT_DIR")"

log "晋升目标库: $LIB_DIR"
log "源文件: $SOURCE_FILE"
log "库内路径: $REL_PATH"

if [[ "$DRY_RUN" == "true" ]]; then
  log "[dry-run] 将复制到 $DEST_FILE 并更新 manifest id=$ASSET_ID"
  exit 0
fi

if [[ "$(read_agent_library_policy_value promote_requires_confirmation "true")" == "true" && "$YES" != "true" ]]; then
  confirm "确认将资产晋升到 05_Agent-Library？" || die "已取消"
fi

mkdir -p "$DEST_DIR"
cp "$SOURCE_FILE" "$DEST_FILE"

python3 "$PY" append \
  --manifest "$MANIFEST_PATH" \
  --id "$ASSET_ID" \
  --title "$TITLE" \
  --type "$ASSET_TYPE" \
  --path "$REL_PATH" \
  --privacy "$PRIVACY" \
  --tags "$TAGS" \
  --triggers "$TRIGGERS" \
  --project-types "$PROJECT_TYPES" \
  --when-to-use "$WHEN_TO_USE" \
  --when-not-to-use "$WHEN_NOT_TO_USE" \
  --source-project "$SOURCE_PROJECT"

if [[ -d "${LIB_DIR}/.git" ]]; then
  require_command git
  (
    cd "$LIB_DIR"
    git add "$DEST_FILE" "$MANIFEST_PATH"
    git commit -m "feat: promote ${ASSET_ID} from ${SOURCE_PROJECT:-manual}"
  )
  log "已在 05_Agent-Library 提交晋升"
else
  warn "05_Agent-Library 未初始化 Git，已复制文件并更新 manifest"
fi

log "晋升完成: $ASSET_ID → $REL_PATH"
