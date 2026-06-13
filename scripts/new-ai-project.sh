#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

PROJECT_NAME=""
PROJECT_TYPE="code"
PRIVACY_PROFILE="code"
PRIVACY_EXPLICIT=false
PROJECT_PURPOSE="待补充项目目标"
GITHUB_MODE="none"
PUSH=false
YES=false
DRY_RUN=false
COMMIT=true
NOTION_HUB_URL="${NOTION_HUB_URL:-待填写}"
NOTION_HUB_TITLE=""

usage() {
  cat <<'EOF'
用法:
  ./scripts/new-ai-project.sh PROJECT_NAME [options]

选项:
  --type code|docs|knowledge|automation|notion-sync
  --privacy code|knowledge|private-local|automation
  --purpose "项目目标"
  --notion-url "Notion Hub URL"
  --notion-title "Notion Hub 标题"
  --github none|private|public
  --push
  --yes
  --no-commit
  --dry-run
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --type) PROJECT_TYPE="$2"; shift 2 ;;
    --privacy) PRIVACY_PROFILE="$2"; PRIVACY_EXPLICIT=true; shift 2 ;;
    --purpose) PROJECT_PURPOSE="$2"; shift 2 ;;
    --notion-url) NOTION_HUB_URL="$2"; shift 2 ;;
    --notion-title) NOTION_HUB_TITLE="$2"; shift 2 ;;
    --github) GITHUB_MODE="$2"; shift 2 ;;
    --push) PUSH=true; shift ;;
    --yes) YES=true; shift ;;
    --no-commit) COMMIT=false; shift ;;
    --dry-run) DRY_RUN=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *)
      if [[ -z "$PROJECT_NAME" ]]; then
        PROJECT_NAME="$1"
        shift
      else
        die "未知参数: $1"
      fi
      ;;
  esac
done

[[ -n "$PROJECT_NAME" ]] || { usage; die "缺少 PROJECT_NAME"; }

if [[ "$PROJECT_TYPE" == "notion-sync" ]]; then
  if [[ "$PRIVACY_EXPLICIT" == "false" ]]; then
    PRIVACY_PROFILE="knowledge"
  fi
  GITHUB_MODE="none"
  PUSH=false
  [[ -n "$NOTION_HUB_TITLE" ]] || NOTION_HUB_TITLE="$PROJECT_NAME"
fi

if ! privacy_profile_allows_github "$PRIVACY_PROFILE"; then
  if [[ "$GITHUB_MODE" != "none" || "$PUSH" == "true" ]]; then
    die "隐私策略 ${PRIVACY_PROFILE} 禁止创建 GitHub 仓库"
  fi
  GITHUB_MODE="none"
fi

ACTIVE_DIR="$(resolve_active_dir)"
TEMPLATE_DIR="$(resolve_template_dir "$PROJECT_TYPE")"
TARGET_DIR="${ACTIVE_DIR}/${PROJECT_NAME}"

[[ -d "$TEMPLATE_DIR" ]] || die "模板目录不存在: $TEMPLATE_DIR"
if [[ -e "$TARGET_DIR" ]]; then die "目标目录已存在: $TARGET_DIR"; fi

log "活动目录: $ACTIVE_DIR"
log "目标项目: $TARGET_DIR"
log "项目类型: $PROJECT_TYPE"
log "隐私策略: $PRIVACY_PROFILE"
log "GitHub 模式: $GITHUB_MODE"

if [[ "$DRY_RUN" == "true" ]]; then
  log "[dry-run] 将创建目录并复制模板"
  log "[dry-run] 隐私策略: $(privacy_profile_description "$PRIVACY_PROFILE")"
  exit 0
fi

mkdir -p "$TARGET_DIR"
cp -R "${TEMPLATE_DIR}/." "$TARGET_DIR/"

while IFS= read -r -d '' file; do
  replace_placeholders "$file" "$PROJECT_NAME" "$PROJECT_TYPE" "$PROJECT_PURPOSE" "$PRIVACY_PROFILE"
done < <(find "$TARGET_DIR" -type f \( -name "*.md" -o -name "*.mdc" -o -name "*.yaml" -o -name "*.yml" \) -print0)

if [[ "$PROJECT_TYPE" != "notion-sync" ]]; then
  wire_agent_library "$TARGET_DIR" "$PROJECT_TYPE" "$PROJECT_PURPOSE" "$PRIVACY_PROFILE"
fi

if [[ "$PROJECT_TYPE" == "notion-sync" ]]; then
  chmod +x "${TARGET_DIR}/scripts/"*.sh 2>/dev/null || true
fi

require_command git
(
  cd "$TARGET_DIR"
  git init -q
  git add .
  if [[ "$COMMIT" == "true" ]]; then
    if [[ "$PROJECT_TYPE" == "notion-sync" ]]; then
      commit_msg="chore: initialize Notion sync project scaffold"
    else
      commit_msg="$(read_policy_value "commit_message" "chore: initialize AI project scaffold")"
    fi
    git commit -m "$commit_msg"
    log "已完成本地 commit: $commit_msg"
  fi
)

check_sensitive_files "$TARGET_DIR" || true

GITHUB_STATUS="none"
if [[ "$GITHUB_MODE" != "none" ]]; then
  if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
    if [[ "$PUSH" == "true" ]]; then
      if confirm "将创建 GitHub ${GITHUB_MODE} 仓库并 push，是否继续？"; then
        (
          cd "$TARGET_DIR"
          if [[ "$GITHUB_MODE" == "private" ]]; then
            gh repo create "$PROJECT_NAME" --private --source=. --remote=origin --push
          else
            gh repo create "$PROJECT_NAME" --public --source=. --remote=origin --push
          fi
        )
        GITHUB_STATUS="${GITHUB_MODE}+pushed"
      fi
    else
      if confirm "将创建 GitHub ${GITHUB_MODE} 仓库（不 push），是否继续？"; then
        (
          cd "$TARGET_DIR"
          if [[ "$GITHUB_MODE" == "private" ]]; then
            gh repo create "$PROJECT_NAME" --private --source=. --remote=origin
          else
            gh repo create "$PROJECT_NAME" --public --source=. --remote=origin
          fi
        )
        GITHUB_STATUS="${GITHUB_MODE}"
      fi
    fi
  else
    warn "gh 未就绪，已跳过 GitHub 创建"
  fi
fi

append_project_index "$PROJECT_NAME" "$TARGET_DIR" "$PROJECT_TYPE" "$GITHUB_STATUS" "created"

cat <<EOF

项目已创建:
  路径: ${TARGET_DIR}
  类型: ${PROJECT_TYPE}
  隐私策略: ${PRIVACY_PROFILE}
  GitHub: ${GITHUB_STATUS}

建议 commit message:
  chore: initialize AI project scaffold
EOF
