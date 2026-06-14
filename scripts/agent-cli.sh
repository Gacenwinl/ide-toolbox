#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

COMMAND="${1:-}"
[[ -n "$COMMAND" ]] || COMMAND="help"
shift || true

PROVIDER=""
MODE=""
MODEL=""
TASK=""
PROJECT_DIR=""
PROJECT_NAME=""
PURPOSE=""
DRY_RUN=false
EXECUTE=false
TRUST=false
CONTEXT_DIR=""

usage() {
  cat <<'EOF'
用法:
  ./scripts/agent-cli.sh start /path/to/project [options]
  ./scripts/agent-cli.sh plan /path/to/project "任务目标" [options]
  ./scripts/agent-cli.sh run /path/to/project "任务目标" [--execute] [options]
  ./scripts/agent-cli.sh milestone /path/to/project [options]
  ./scripts/agent-cli.sh new-notion PROJECT_NAME --purpose "项目目标" [options]

选项:
  --provider cursor|codex
  --mode plan|ask
  --model MODEL
  --purpose "项目目标"       # new-notion
  --dry-run                 # 只生成 prompt，不调用 Agent
  --execute                 # run 命令允许执行模式
  --trust                   # 传给 cursor agent --trust（仅 headless）
  -h, --help
EOF
}

case "$COMMAND" in
  start|plan|run|milestone|new-notion|help) ;;
  -h|--help) usage; exit 0 ;;
  *) die "未知命令: $COMMAND" ;;
esac

if [[ "$COMMAND" == "help" ]]; then
  usage
  exit 0
fi

if [[ "$COMMAND" == "new-notion" ]]; then
  PROJECT_NAME="${1:-}"
  [[ -n "$PROJECT_NAME" ]] || die "new-notion 缺少 PROJECT_NAME"
  shift || true
else
  PROJECT_DIR="${1:-}"
  [[ -n "$PROJECT_DIR" ]] || die "${COMMAND} 缺少项目路径"
  shift || true
  [[ -d "$PROJECT_DIR" ]] || die "目录不存在: $PROJECT_DIR"
  PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"
  if [[ "$COMMAND" == "plan" || "$COMMAND" == "run" ]]; then
    TASK="${1:-}"
    [[ -n "$TASK" ]] || die "${COMMAND} 缺少任务目标"
    shift || true
  fi
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --provider) PROVIDER="$2"; shift 2 ;;
    --mode) MODE="$2"; shift 2 ;;
    --model) MODEL="$2"; shift 2 ;;
    --purpose) PURPOSE="$2"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    --execute) EXECUTE=true; shift ;;
    --trust) TRUST=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *)
      if [[ -z "$TASK" && "$COMMAND" != "new-notion" ]]; then
        TASK="$1"
        shift
      else
        die "未知参数: $1"
      fi
      ;;
  esac
done

PROVIDER="$(resolve_agent_cli_provider "$PROVIDER")"
MODEL="${MODEL:-$(read_agent_cli_policy_value default_model "")}"

case "$COMMAND" in
  start|plan)
    MODE="${MODE:-plan}"
    ;;
  milestone)
    MODE="${MODE:-}"
    ;;
  *)
    MODE="${MODE:-$(read_agent_cli_policy_value default_mode plan)}"
    ;;
esac

if [[ "$COMMAND" == "run" && "$EXECUTE" != "true" ]]; then
  MODE="plan"
fi

if [[ "$EXECUTE" == "true" && "$(read_agent_cli_policy_value allow_execute false)" != "true" ]]; then
  die "config/agent_cli.allow_execute=false。请在 project-policy.yaml 设为 true 后再用 run --execute，或先用 plan/start。"
fi

if [[ -z "$TASK" ]]; then
  case "$COMMAND" in
    start) TASK="接手项目并汇报当前状态，不要改文件" ;;
    milestone) TASK="做里程碑收尾：更新 ai-context，列出已完成、下一步、验证、回滚、建议 commit message" ;;
    new-notion) TASK="${PURPOSE:-新建 Notion 双轨项目}" ;;
  esac
fi

if [[ "$COMMAND" == "new-notion" ]]; then
  [[ -n "$PURPOSE" ]] || die "new-notion 需要 --purpose"
  if [[ "$DRY_RUN" == "true" ]]; then
    "${SCRIPT_DIR}/new-ai-project.sh" "$PROJECT_NAME" --type notion-sync --privacy knowledge --purpose "$PURPOSE" --github none --dry-run
    PROJECT_DIR="$(resolve_active_dir)/${PROJECT_NAME}"
    PROJECT_TYPE="notion-sync"
    PRIVACY_PROFILE="knowledge"
    CONTEXT_DIR="${TOOLBOX_ROOT}/templates/notion-project"
  else
    "${SCRIPT_DIR}/new-ai-project.sh" "$PROJECT_NAME" --type notion-sync --privacy knowledge --purpose "$PURPOSE" --github none
    PROJECT_DIR="$(resolve_active_dir)/${PROJECT_NAME}"
  fi
  TASK="$PURPOSE"
  COMMAND="new-notion"
fi

PROJECT_TYPE="${PROJECT_TYPE:-$(detect_project_type "$PROJECT_DIR")}"
PRIVACY_PROFILE="${PRIVACY_PROFILE:-$(detect_project_privacy "$PROJECT_DIR")}"
TEMPLATE_NAME="$COMMAND"
if [[ "$COMMAND" == "new-notion" ]]; then
  TEMPLATE_NAME="new-notion"
fi
TEMPLATE_FILE="${TOOLBOX_ROOT}/templates/agent-cli/${TEMPLATE_NAME}.md"
[[ -f "$TEMPLATE_FILE" ]] || die "缺少 Agent CLI 模板: $TEMPLATE_FILE"

SUGGESTED_FILE="$(mktemp)"
PROMPT_FILE="$(mktemp)"
trap 'rm -f "$SUGGESTED_FILE" "$PROMPT_FILE"' EXIT

"${SCRIPT_DIR}/query-agent-assets.sh" \
  --task "$TASK" \
  --type "$PROJECT_TYPE" \
  --privacy "$PRIVACY_PROFILE" \
  --output "$SUGGESTED_FILE" >/dev/null || true

python3 "${SCRIPT_DIR}/agent-cli-prompt.py" \
  --template "$TEMPLATE_FILE" \
  --project "$PROJECT_DIR" \
  --context-dir "${CONTEXT_DIR:-$PROJECT_DIR}" \
  --project-type "$PROJECT_TYPE" \
  --privacy "$PRIVACY_PROFILE" \
  --task "$TASK" \
  --suggested-assets "$SUGGESTED_FILE" > "$PROMPT_FILE"

if [[ -d "${PROJECT_DIR}/.git" ]]; then
  if git -C "$PROJECT_DIR" status --porcelain | grep -q .; then
    warn "目标项目 Git 工作区不干净:"
    git -C "$PROJECT_DIR" status --short --branch
    if [[ "$EXECUTE" == "true" && "$(read_agent_cli_policy_value require_clean_git_for_execute true)" == "true" ]]; then
      die "执行模式要求干净工作区。请先提交/处理变更，或仅使用 plan/start。"
    fi
  fi
fi

if [[ "$COMMAND" == "milestone" ]]; then
  log "里程碑预检: project-health + session-handoff"
  "${SCRIPT_DIR}/project-health.sh" "$PROJECT_DIR" || true
  "${SCRIPT_DIR}/session-handoff.sh" "$PROJECT_DIR" --dry-run || true
fi

if [[ "$DRY_RUN" == "true" ]]; then
  printf '%s\n' "----- Agent CLI dry-run prompt -----"
  cat "$PROMPT_FILE"
  exit 0
fi

cursor_args=(agent --print --workspace "$PROJECT_DIR")
case "$MODE" in
  plan|ask) cursor_args+=(--mode "$MODE") ;;
  "") ;;
  *) die "不支持的 mode: $MODE" ;;
esac
if [[ -n "$MODEL" ]]; then
  cursor_args+=(--model "$MODEL")
fi
if [[ "$TRUST" == "true" && "$(read_agent_cli_policy_value allow_trust true)" == "true" ]]; then
  cursor_args+=(--trust)
fi

case "$PROVIDER" in
  cursor)
    cursor "${cursor_args[@]}" "$(cat "$PROMPT_FILE")"
    ;;
  codex)
    die "Codex provider 尚未实现。当前可用: --provider cursor"
    ;;
esac

if [[ "$COMMAND" == "run" && "$EXECUTE" == "true" ]]; then
  if [[ "$(read_agent_cli_policy_value run_health_after_execute true)" == "true" ]]; then
    "${SCRIPT_DIR}/project-health.sh" "$PROJECT_DIR" || true
  fi
  if [[ "$(read_agent_cli_policy_value run_handoff_after_execute true)" == "true" ]]; then
    "${SCRIPT_DIR}/session-handoff.sh" "$PROJECT_DIR" --dry-run || true
  fi
fi
