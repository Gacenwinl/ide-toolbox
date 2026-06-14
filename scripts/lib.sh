#!/usr/bin/env bash
# Shared helpers for ide-toolbox automation scripts.

set -euo pipefail

TOOLBOX_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
POLICY_FILE="${TOOLBOX_ROOT}/config/project-policy.yaml"
INDEX_FILE="${TOOLBOX_ROOT}/projects-index.md"
RECENT_PROJECT_PATHS=()

read_policy_value() {
  local key="$1"
  local default="${2:-}"
  if [[ ! -f "$POLICY_FILE" ]]; then
    echo "$default"
    return
  fi
  local value
  value="$(grep -E "^[[:space:]]*${key}:" "$POLICY_FILE" | head -n1 | sed -E 's/^[^:]*:[[:space:]]*"?([^"#]*)"?.*/\1/' | sed -E 's/[[:space:]]+$//')"
  if [[ -z "$value" ]]; then
    echo "$default"
  else
    echo "$value"
  fi
}

read_device_policy_value() {
  local profile="$1"
  local key="$2"
  local default="${3:-}"
  if [[ ! -f "$POLICY_FILE" ]]; then
    echo "$default"
    return
  fi
  awk -v profile="$profile" -v key="$key" -v default="$default" '
    $0 ~ "^  " profile ":" { in_profile=1; next }
    in_profile && $0 ~ /^  [A-Za-z0-9_-]+:/ && $0 !~ "^  " profile ":" { in_profile=0 }
    in_profile && $0 ~ "^    " key ":" {
      line=$0
      sub(/^[^:]*:[ ]*"?/, "", line)
      sub(/".*$/, "", line)
      gsub(/[[:space:]]+$/, "", line)
      print line
      found=1
      exit
    }
    END { if (!found) print default }
  ' "$POLICY_FILE"
}

read_recent_policy_value() {
  local key="$1"
  local default="${2:-}"
  if [[ ! -f "$POLICY_FILE" ]]; then
    echo "$default"
    return
  fi
  awk -v key="$key" -v default="$default" '
    /^recent_projects:/ { in_section=1; next }
    in_section && /^[A-Za-z]/ && $0 !~ /^  / { in_section=0 }
    in_section && $0 ~ "^  " key ":" {
      line=$0
      sub(/^[^:]*:[ ]*"?/, "", line)
      sub(/".*$/, "", line)
      gsub(/[[:space:]]+$/, "", line)
      print line
      found=1
      exit
    }
    END { if (!found) print default }
  ' "$POLICY_FILE"
}

read_agent_cli_policy_value() {
  local key="$1"
  local default="${2:-}"
  if [[ ! -f "$POLICY_FILE" ]]; then
    echo "$default"
    return
  fi
  awk -v key="$key" -v default="$default" '
    /^agent_cli:/ { in_section=1; next }
    in_section && /^[A-Za-z]/ && $0 !~ /^  / { in_section=0 }
    in_section && $0 ~ "^  " key ":" {
      line=$0
      sub(/^[^:]*:[ ]*"?/, "", line)
      sub(/".*$/, "", line)
      gsub(/[[:space:]]+$/, "", line)
      print line
      found=1
      exit
    }
    END { if (!found) print default }
  ' "$POLICY_FILE"
}

detect_device_profile() {
  if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    echo "windows"
    return
  fi
  if [[ "$(uname -s 2>/dev/null)" == "Darwin" ]]; then
    local host
    host="$(hostname -s 2>/dev/null | tr '[:upper:]' '[:lower:]')"
    case "$host" in
      *mini*) echo "macmini" ;;
      *) echo "macbook" ;;
    esac
    return
  fi
  echo "windows"
}

current_device_name() {
  hostname -s 2>/dev/null || echo "unknown-device"
}

resolve_active_dir() {
  local profile nas_path sync_path device_path
  profile="$(detect_device_profile)"
  # 1) devices.<profile>.active_projects（MacBook=Drive 同步, Mac mini=NAS 挂载, Windows=Drive 同步）
  device_path="$(read_device_policy_value "$profile" "active_projects" "")"
  if [[ -n "$device_path" && "$device_path" != "待填写 Windows 映射盘路径" && -d "$device_path" ]]; then
    echo "$device_path"
    return
  fi
  nas_path="$(read_policy_value "active_projects" "/Volumes/home/Drive/00_FileStation")"
  sync_path="$(read_policy_value "active_projects_cursor_sync" "/Users/dawncity/Library/CloudStorage/SynologyDrive-FileStation")"
  if [[ -d "$nas_path" ]]; then
    echo "$nas_path"
  elif [[ -d "$sync_path" ]]; then
    echo "$sync_path"
  else
    if [[ "$profile" == "windows" ]]; then
      die "找不到 Windows 活动项目目录。请在 config/project-policy.yaml 的 devices.windows.active_projects 填写映射盘路径。"
    fi
    die "找不到活动项目目录: $nas_path 或 $sync_path"
  fi
}

resolve_archive_dir() {
  local nas_path
  nas_path="$(read_policy_value "archive_projects" "/Volumes/home/Drive/01_Project Files")"
  if [[ ! -d "$nas_path" ]]; then
    die "找不到归档目录: $nas_path"
  fi
  echo "$nas_path"
}

resolve_agent_library_dir() {
  local profile nas_path sync_path win_path resources_path
  profile="$(detect_device_profile)"
  nas_path="$(read_policy_value "agent_library" "")"
  sync_path="$(read_policy_value "agent_library_cursor_sync" "")"
  win_path="$(read_policy_value "agent_library_windows_sync" "")"
  resources_path="$(read_policy_value "resources" "")"

  if [[ "$profile" == "windows" && -n "$win_path" && -d "$win_path" ]]; then
    echo "$win_path"
    return
  fi
  if [[ -n "$sync_path" && -d "$sync_path" ]]; then
    echo "$sync_path"
    return
  fi
  if [[ -n "$resources_path" && -d "${resources_path}/05_Agent-Library" ]]; then
    echo "${resources_path}/05_Agent-Library"
    return
  fi
  if [[ -n "$nas_path" && -d "$nas_path" ]]; then
    echo "$nas_path"
    return
  fi
  if [[ "$profile" == "macbook" && -n "$sync_path" ]]; then
    echo "$sync_path"
    return
  fi
  if [[ -n "$nas_path" ]]; then
    echo "$nas_path"
    return
  fi
  die "找不到 Agent Library 目录。请运行 ./scripts/init-agent-library.sh 或检查 config/project-policy.yaml"
}

privacy_profile_allows_agent_library() {
  local profile="$1"
  [[ "$profile" != "private-local" ]]
}

read_agent_library_policy_value() {
  local key="$1"
  local default="${2:-}"
  if [[ ! -f "$POLICY_FILE" ]]; then
    echo "$default"
    return
  fi
  awk -v key="$key" -v default="$default" '
    /^agent_library:/ { in_section=1; next }
    in_section && /^[A-Za-z]/ && $0 !~ /^  / { in_section=0 }
    in_section && $0 ~ "^  " key ":" {
      line=$0
      sub(/^[^:]*:[ ]*"?/, "", line)
      sub(/".*$/, "", line)
      gsub(/[[:space:]]+$/, "", line)
      print line
      found=1
      exit
    }
    END { if (!found) print default }
  ' "$POLICY_FILE"
}

list_recent_projects() {
  local active_dir limit max_age_days cutoff now name path mtime
  active_dir="$(resolve_active_dir)"
  limit="$(read_recent_policy_value "limit" "5")"
  max_age_days="$(read_recent_policy_value "max_age_days" "7")"
  now="$(date +%s)"
  if [[ "$max_age_days" =~ ^[0-9]+$ ]] && (( max_age_days > 0 )); then
    cutoff=$((now - max_age_days * 86400))
  else
    cutoff=0
  fi
  RECENT_PROJECT_PATHS=()
  while IFS= read -r path; do
    name="$(basename "$path")"
    [[ "$name" == "ide-toolbox" ]] && continue
    [[ "$name" == .* ]] && continue
    if (( cutoff > 0 )); then
      if stat -f "%m" "$path" >/dev/null 2>&1; then
        mtime="$(stat -f "%m" "$path")"
      else
        mtime="$(stat -c "%Y" "$path")"
      fi
      (( mtime >= cutoff )) || continue
    fi
    RECENT_PROJECT_PATHS+=("$path")
    [[ "${#RECENT_PROJECT_PATHS[@]}" -ge "$limit" ]] && break
  done < <(
    find "$active_dir" -mindepth 1 -maxdepth 1 -type d ! -name "ide-toolbox" -print0 2>/dev/null \
      | while IFS= read -r -d '' dir; do
          if stat -f "%m %N" "$dir" >/dev/null 2>&1; then
            stat -f "%m %N" "$dir"
          else
            stat -c "%Y %n" "$dir"
          fi
        done \
      | sort -rn \
      | cut -d' ' -f2-
  )
}

print_recent_projects() {
  local i=1
  list_recent_projects
  if [[ "${#RECENT_PROJECT_PATHS[@]}" -eq 0 ]]; then
    printf '  (暂无最近活动项目)\n'
    return
  fi
  for path in "${RECENT_PROJECT_PATHS[@]}"; do
    printf '  %2d) %s\n' "$i" "$(basename "$path")"
    i=$((i + 1))
  done
}

select_recent_project() {
  local choice="$1"
  list_recent_projects
  if (( choice < 1 || choice > 10 )); then
    die "无效项目编号: ${choice}（快速打开为 1-10）"
  fi
  if (( choice > ${#RECENT_PROJECT_PATHS[@]} )); then
    die "编号 ${choice} 无对应项目（当前仅 ${#RECENT_PROJECT_PATHS[@]} 个最近项目）"
  fi
  printf '%s' "${RECENT_PROJECT_PATHS[$((choice - 1))]}"
}

privacy_profile_allows_github() {
  local profile="$1"
  case "$profile" in
    private-local) return 1 ;;
    *) return 0 ;;
  esac
}

privacy_profile_description() {
  local profile="$1"
  case "$profile" in
    code) echo "普通代码/自动化项目，可选 GitHub private" ;;
    knowledge) echo "知识库项目，默认不上 GitHub，谨慎 push" ;;
    private-local) echo "求职/签证/证件类，仅本地与 NAS，禁止 GitHub" ;;
    automation) echo "脚本/工具项目，可选 GitHub private" ;;
    *) echo "未定义隐私策略" ;;
  esac
}

resolve_template_dir() {
  local project_type="$1"
  case "$project_type" in
    notion-sync) echo "${TOOLBOX_ROOT}/templates/notion-project" ;;
    *) echo "${TOOLBOX_ROOT}/templates/ai-project" ;;
  esac
}

is_notion_project() {
  local dir="$1"
  [[ -f "${dir}/manifest.yaml" && -f "${dir}/NOTION_INDEX.md" ]]
}

detect_project_type() {
  local dir="$1"
  if is_notion_project "$dir"; then
    echo "notion-sync"
  elif [[ -f "${dir}/docs/ai-context.md" ]]; then
    awk '
      /^## Source Of Truth/ { exit }
      /^## Privacy Profile/ { in_privacy=1; next }
      /^## / && in_privacy { in_privacy=0 }
      /^## Purpose/ { in_purpose=1; next }
      /^## / && in_purpose { in_purpose=0 }
      END { print "code" }
    ' "${dir}/docs/ai-context.md" >/dev/null 2>&1 || true
    echo "code"
  else
    echo "code"
  fi
}

detect_project_privacy() {
  local dir="$1"
  if [[ -f "${dir}/docs/agent-library.md" ]]; then
    if grep -q "Privacy Profile: \`private-local\`" "${dir}/docs/agent-library.md" 2>/dev/null; then
      echo "private-local"
      return
    fi
    if grep -q "Privacy Profile: \`knowledge\`" "${dir}/docs/agent-library.md" 2>/dev/null; then
      echo "knowledge"
      return
    fi
    if grep -q "Privacy Profile: \`automation\`" "${dir}/docs/agent-library.md" 2>/dev/null; then
      echo "automation"
      return
    fi
  fi
  if [[ -f "${dir}/docs/ai-context.md" ]] && grep -q "Profile: \`private-local\`" "${dir}/docs/ai-context.md" 2>/dev/null; then
    echo "private-local"
    return
  fi
  echo "code"
}

cursor_agent_available() {
  command -v cursor >/dev/null 2>&1 && cursor agent --help >/dev/null 2>&1
}

resolve_agent_cli_provider() {
  local requested="${1:-}"
  local default_provider
  default_provider="$(read_agent_cli_policy_value default_provider cursor)"
  requested="${requested:-$default_provider}"
  case "$requested" in
    cursor)
      cursor_agent_available || die "Cursor Agent CLI 不可用。请确认 cursor 已安装且支持: cursor agent --help"
      echo "cursor"
      ;;
    codex)
      command -v codex >/dev/null 2>&1 || die "Codex CLI 不可用。当前第一版建议使用 --provider cursor"
      echo "codex"
      ;;
    *)
      die "未知 Agent CLI provider: $requested"
      ;;
  esac
}

replace_placeholders() {
  local file="$1"
  local project_name="$2"
  local project_type="$3"
  local project_purpose="$4"
  local privacy_profile="${5:-code}"
  local privacy_desc
  local created_date="${CREATED_DATE:-$(date +%Y-%m-%d)}"
  local notion_hub_url="${NOTION_HUB_URL:-待填写}"
  local notion_hub_title="${NOTION_HUB_TITLE:-$project_name}"
  local agent_library_path="${AGENT_LIBRARY_PATH:-$(resolve_agent_library_dir 2>/dev/null || echo "待初始化")}"
  privacy_desc="$(privacy_profile_description "$privacy_profile")"
  if [[ "$(uname)" == "Darwin" ]]; then
    sed -i '' "s/{{PROJECT_NAME}}/${project_name//\//\\/}/g" "$file"
    sed -i '' "s/{{PROJECT_TYPE}}/${project_type//\//\\/}/g" "$file"
    sed -i '' "s/{{PROJECT_PURPOSE}}/${project_purpose//\//\\/}/g" "$file"
    sed -i '' "s/{{PRIVACY_PROFILE}}/${privacy_profile//\//\\/}/g" "$file"
    sed -i '' "s/{{PRIVACY_DESCRIPTION}}/${privacy_desc//\//\\/}/g" "$file"
    sed -i '' "s/{{CREATED_DATE}}/${created_date//\//\\/}/g" "$file"
    sed -i '' "s|{{NOTION_HUB_URL}}|${notion_hub_url//\//\\/}|g" "$file"
    sed -i '' "s/{{NOTION_HUB_TITLE}}/${notion_hub_title//\//\\/}/g" "$file"
    sed -i '' "s|{{AGENT_LIBRARY_PATH}}|${agent_library_path//\//\\/}|g" "$file"
  else
    sed -i "s/{{PROJECT_NAME}}/${project_name//\//\\/}/g" "$file"
    sed -i "s/{{PROJECT_TYPE}}/${project_type//\//\\/}/g" "$file"
    sed -i "s/{{PROJECT_PURPOSE}}/${project_purpose//\//\\/}/g" "$file"
    sed -i "s/{{PRIVACY_PROFILE}}/${privacy_profile//\//\\/}/g" "$file"
    sed -i "s/{{PRIVACY_DESCRIPTION}}/${privacy_desc//\//\\/}/g" "$file"
    sed -i "s/{{CREATED_DATE}}/${created_date//\//\\/}/g" "$file"
    sed -i "s|{{NOTION_HUB_URL}}|${notion_hub_url//\//\\/}|g" "$file"
    sed -i "s/{{NOTION_HUB_TITLE}}/${notion_hub_title//\//\\/}/g" "$file"
    sed -i "s|{{AGENT_LIBRARY_PATH}}|${agent_library_path//\//\\/}|g" "$file"
  fi
}

log() {
  printf '[ide-toolbox] %s\n' "$*"
}

warn() {
  printf '[ide-toolbox][warn] %s\n' "$*" >&2
}

die() {
  printf '[ide-toolbox][error] %s\n' "$*" >&2
  exit 1
}

confirm() {
  local prompt="$1"
  if [[ "${YES:-false}" == "true" ]]; then
    return 0
  fi
  read -r -p "${prompt} [y/N] " reply
  [[ "$reply" =~ ^[Yy]$ ]]
}

require_command() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || die "缺少命令: $cmd"
}

append_project_index() {
  local name="$1"
  local path="$2"
  local type="$3"
  local github="$4"
  local status="$5"
  local date
  date="$(date +%Y-%m-%d)"
  if [[ ! -f "$INDEX_FILE" ]]; then
    return
  fi
  cat >> "$INDEX_FILE" <<EOF

| ${name} | active | ${path} | ${type} | ${github} | ${status} | ${date} |
EOF
}

normalize_dragged_path() {
  local raw="$*"
  raw="${raw%$'\r'}"
  raw="${raw#"${raw%%[![:space:]]*}"}"
  raw="${raw%"${raw##*[![:space:]]}"}"
  raw="${raw#\"}"
  raw="${raw%\"}"
  raw="${raw#\'}"
  raw="${raw%\'}"
  printf '%s' "$raw"
}

check_sensitive_files() {
  local dir="$1"
  local patterns=(
    ".env"
    "*.pem"
    "*.key"
    "*secret*"
    "*credential*"
    "*password*"
  )
  local found=0
  for pattern in "${patterns[@]}"; do
    if find "$dir" -maxdepth 3 -iname "$pattern" 2>/dev/null | grep -q .; then
      found=1
      warn "检测到疑似敏感文件模式: $pattern"
    fi
  done
  if [[ "$found" -eq 1 ]]; then
    warn "请确认这些文件不会被提交到 Git。"
    return 1
  fi
  return 0
}

project_missing_scaffold() {
  local dir="$1"
  if is_notion_project "$dir"; then
    [[ ! -f "${dir}/AGENTS.md" || ! -f "${dir}/docs/HANDOFF.md" || ! -f "${dir}/docs/ai-context.md" ]]
  else
    [[ ! -f "${dir}/AGENTS.md" || ! -f "${dir}/docs/runbook.md" || ! -f "${dir}/docs/ai-context.md" ]]
  fi
}

project_upgrade_scan_candidate() {
  local dir="$1"
  local name
  name="$(basename "$dir")"

  [[ "$name" == .* ]] && return 1
  [[ "$name" == "ide-toolbox" ]] && return 1
  [[ "$name" == "05_Agent-Library" ]] && return 1

  if [[ -d "${dir}/.git" || -f "${dir}/AGENTS.md" || -f "${dir}/manifest.yaml" || -f "${dir}/README.md" ]]; then
    return 0
  fi

  [[ "$name" =~ ^[0-9]{6}[-_] ]]
}

project_missing_agent_library_hook() {
  local dir="$1"
  [[ ! -f "${dir}/docs/agent-library.md" || ! -f "${dir}/docs/suggested-assets.md" || ! -f "${dir}/docs/ai-context.md" ]]
}

plain_menu_select() {
  local title="$1"
  shift
  local options=("$@")
  local i=0 slot=0 label="" choice
  printf '\n%s\n' "$title" >&2
  for opt in "${options[@]}"; do
    slot=$((i + 1))
    label="$opt"
    if [[ "$opt" =~ ^\[([0-9]+)\][[:space:]]*(.*)$ ]]; then
      slot="${BASH_REMATCH[1]}"
      label="${BASH_REMATCH[2]}"
    fi
    printf '  %2d) %s\n' "$slot" "$label" >&2
    i=$((i + 1))
  done
  if [[ -r /dev/tty ]]; then
    read -r -p "请输入数字: " choice </dev/tty
  else
    read -r -p "请输入数字: " choice
  fi
  printf '%s' "$choice"
}

is_toolbox_project() {
  local dir="$1"
  [[ "$(cd "$dir" 2>/dev/null && pwd -P)" == "$(cd "$TOOLBOX_ROOT" 2>/dev/null && pwd -P)" ]]
}

wire_agent_library() {
  local target_dir="$1"
  local project_type="$2"
  local project_purpose="$3"
  local privacy_profile="$4"
  local query_on_new
  local lib_dir manifest_script count

  query_on_new="$(read_agent_library_policy_value query_on_new_project "true")"
  lib_dir="$(resolve_agent_library_dir 2>/dev/null || echo "")"

  if [[ -z "$lib_dir" || ! -d "$lib_dir" ]]; then
    warn "Agent Library 未就绪，跳过 wire（可运行 init-agent-library.sh）"
    return 0
  fi

  export AGENT_LIBRARY_PATH="$lib_dir"
  if [[ -f "${target_dir}/docs/agent-library.md" ]]; then
    replace_placeholders "${target_dir}/docs/agent-library.md" "$(basename "$target_dir")" "$project_type" "$project_purpose" "$privacy_profile"
  fi

  if [[ "$query_on_new" != "true" ]] || ! privacy_profile_allows_agent_library "$privacy_profile"; then
    if [[ -f "${target_dir}/docs/suggested-assets.md" ]]; then
      cat > "${target_dir}/docs/suggested-assets.md" <<EOF
# Suggested Agent Library Assets

- Privacy: \`${privacy_profile}\`
- Status: 已跳过共享 Agent Library（private-local 或策略关闭）

仅使用项目内 \`docs/\` 文件。
EOF
    fi
    log "private-local / 策略跳过 Agent Library 查询"
    return 0
  fi

  manifest_script="${TOOLBOX_ROOT}/scripts/query-agent-assets.sh"
  [[ -x "$manifest_script" ]] || manifest_script="${TOOLBOX_ROOT}/scripts/query-agent-assets.sh"
  bash "$manifest_script" \
    --purpose "$project_purpose" \
    --type "$project_type" \
    --privacy "$privacy_profile" \
    --output "${target_dir}/docs/suggested-assets.md" >/dev/null

  count="$(grep -cE '^[0-9]+\. \*\*' "${target_dir}/docs/suggested-assets.md" 2>/dev/null || echo 0)"
  log "Agent Library 已匹配建议资产条目: ${count}"
}

file_mtime_epoch() {
  local f="$1"
  [[ -f "$f" ]] || { echo 0; return 0; }
  if stat -f %m "$f" >/dev/null 2>&1; then
    stat -f %m "$f"
  else
    stat -c %Y "$f"
  fi
}

read_handoff_policy_value() {
  local key="$1"
  local default="${2:-}"
  if [[ ! -f "$POLICY_FILE" ]]; then
    echo "$default"
    return
  fi
  awk -v key="$key" -v default="$default" '
    /^handoff:/ { in_section=1; next }
    in_section && /^[A-Za-z]/ && $0 !~ /^  / { in_section=0 }
    in_section && $0 ~ "^  " key ":" {
      line=$0
      sub(/^[^:]*:[ ]*"?/, "", line)
      sub(/".*$/, "", line)
      gsub(/[[:space:]]+$/, "", line)
      print line
      found=1
      exit
    }
    END { if (!found) print default }
  ' "$POLICY_FILE"
}

# 审计文档同步：供 session-handoff / project-health 调用
# 用法: audit_doc_sync /path ok_fn warn_fn   （ok_fn/warn_fn 为函数名）
audit_doc_sync() {
  local target_dir="$1"
  local ok_fn="$2"
  local warn_fn="$3"
  local ai_context="${target_dir}/docs/ai-context.md"
  local now changelog_mtime age_days skew readme_mtime html_mtime runbook_mtime
  local verify_checklist stale_days skew_sec changelog_mtime

  verify_checklist="$(read_handoff_policy_value verify_doc_sync_checklist true)"
  stale_days="$(read_handoff_policy_value warn_stale_readme_after_changelog_days 7)"
  skew_sec="$(read_handoff_policy_value readme_lag_seconds 172800)"

  if [[ "$verify_checklist" != "true" || ! -f "$ai_context" ]]; then
    return 0
  fi

  if grep -q "## 文档同步清单" "$ai_context" 2>/dev/null; then
    local unchecked
    unchecked="$(awk '
      /^## 文档同步清单/ { flag=1; next }
      flag && /^## / { exit }
      flag && /^- \[ \]/ { count++ }
      END { print count+0 }
    ' "$ai_context")"
    if [[ "$unchecked" -gt 0 ]]; then
      "$warn_fn" "文档同步清单仍有 ${unchecked} 项未勾选 — milestone 后应全部 [x] 或删除过时项"
    else
      "$ok_fn" "文档同步清单已全部勾选"
    fi
  else
    "$warn_fn" "ai-context 缺少「文档同步清单」节（upgrade 或 milestone 时补齐）"
  fi

  changelog_mtime=0
  if [[ -f "${target_dir}/docs/changelog.md" ]]; then
    changelog_mtime="$(file_mtime_epoch "${target_dir}/docs/changelog.md")"
  fi

  if [[ "$changelog_mtime" -gt 0 ]]; then
    now="$(date +%s)"
    age_days=$(( (now - changelog_mtime) / 86400 ))
    if [[ "$age_days" -le "$stale_days" ]]; then
      local rel doc_file fm
      for rel in README.md README.html docs/runbook.md; do
        doc_file="${target_dir}/${rel}"
        [[ -f "$doc_file" ]] || continue
        fm="$(file_mtime_epoch "$doc_file")"
        if [[ "$fm" -lt $((changelog_mtime - skew_sec)) ]]; then
          "$warn_fn" "${rel} 可能未随 docs/changelog.md 同步（changelog 近 ${stale_days} 天内有更新）"
        else
          "$ok_fn" "${rel} 与 changelog 更新时间一致（或更新）"
        fi
      done
    fi
  fi

  if [[ -f "$ai_context" ]]; then
    local ctx_mtime readme_m
    ctx_mtime="$(file_mtime_epoch "$ai_context")"
    if [[ -f "${target_dir}/README.md" ]]; then
      readme_m="$(file_mtime_epoch "${target_dir}/README.md")"
      if [[ "$ctx_mtime" -gt "$readme_m" && "$ctx_mtime" -gt $((readme_m + skew_sec)) ]]; then
        "$warn_fn" "ai-context 比 README.md 新很多 — 是否忘记同步 README"
      fi
    fi
  fi
}

sanitize_menu_choice() {
  local raw="$1"
  raw="${raw//$'\r'/}"
  raw="${raw//$'\n'/}"
  raw="$(printf '%s' "$raw" | tr -cd '0-9')"
  printf '%s' "$raw"
}

interactive_menu_select() {
  local title="$1"
  shift
  local options=("$@")
  local py="${TOOLBOX_ROOT}/scripts/interactive-menu.py"
  local choice=""

  [[ "${#options[@]}" -gt 0 ]] || die "菜单为空"

  if [[ "${IDE_MENU_PLAIN:-}" == "1" ]] || [[ ! -t 0 ]]; then
    plain_menu_select "$title" "${options[@]}"
    return 0
  fi

  if command -v python3 >/dev/null 2>&1 && [[ -f "$py" ]]; then
    choice="$(python3 "$py" "$title" "${options[@]}" 2>/dev/tty)" || choice=""
    choice="$(sanitize_menu_choice "$choice")"
    if [[ -n "$choice" ]]; then
      printf '%s' "$choice"
      return 0
    fi
  fi

  plain_menu_select "$title" "${options[@]}"
}
