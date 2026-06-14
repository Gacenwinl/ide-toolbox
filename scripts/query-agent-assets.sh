#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

TASK=""
PURPOSE=""
PROJECT_TYPE=""
PRIVACY="code"
FORMAT="markdown"
OUTPUT=""
MIN_SCORE="2"

usage() {
  cat <<'EOF'
用法:
  ./scripts/query-agent-assets.sh [options]

选项:
  --task "任务关键词"
  --purpose "项目目标"
  --type code|docs|knowledge|automation|notion-sync
  --privacy code|knowledge|private-local|automation
  --format markdown|json
  --output /path/to/suggested-assets.md
  --min-score N
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --task) TASK="$2"; shift 2 ;;
    --purpose) PURPOSE="$2"; shift 2 ;;
    --type) PROJECT_TYPE="$2"; shift 2 ;;
    --privacy) PRIVACY="$2"; shift 2 ;;
    --format) FORMAT="$2"; shift 2 ;;
    --output) OUTPUT="$2"; shift 2 ;;
    --min-score) MIN_SCORE="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) die "未知参数: $1" ;;
  esac
done

require_command python3

if ! privacy_profile_allows_agent_library "$PRIVACY"; then
  result="# Agent Library Query\n\nprivate-local 项目已跳过共享库查询。\n"
  if [[ -n "$OUTPUT" ]]; then
    mkdir -p "$(dirname "$OUTPUT")"
    printf '%b' "$result" > "$OUTPUT"
    log "已写入（跳过）: $OUTPUT"
  else
    printf '%b' "$result"
  fi
  exit 0
fi

library_dir="$(resolve_agent_library_dir)"
manifest_name="$(read_agent_library_policy_value manifest "manifest.yaml")"
manifest_file="${library_dir}/${manifest_name}"
python_helper="${SCRIPT_DIR}/agent-library.py"

[[ -f "$manifest_file" ]] || die "manifest 不存在: ${manifest_file}（请先运行 init-agent-library.sh）"

result="$(python3 "$python_helper" query \
  --manifest "$manifest_file" \
  --library-dir "$library_dir" \
  --task "$TASK" \
  --purpose "$PURPOSE" \
  --type "$PROJECT_TYPE" \
  --privacy "$PRIVACY" \
  --format "$FORMAT" \
  --min-score "$MIN_SCORE")"

if [[ -n "$OUTPUT" ]]; then
  mkdir -p "$(dirname "$OUTPUT")"
  printf '%s' "$result" > "$OUTPUT"
  log "已写入: $OUTPUT"
else
  printf '%s' "$result"
fi
