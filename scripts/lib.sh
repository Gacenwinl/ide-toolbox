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

list_recent_projects() {
  local active_dir limit exclude name path mtime
  active_dir="$(resolve_active_dir)"
  limit="$(read_policy_value "limit" "10")"
  RECENT_PROJECT_PATHS=()
  while IFS= read -r path; do
    name="$(basename "$path")"
    [[ "$name" == "ide-toolbox" ]] && continue
    [[ "$name" == .* ]] && continue
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
  if [[ "$choice" -lt 1 || "$choice" -gt "${#RECENT_PROJECT_PATHS[@]}" ]]; then
    die "无效项目编号: $choice"
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
  else
    sed -i "s/{{PROJECT_NAME}}/${project_name//\//\\/}/g" "$file"
    sed -i "s/{{PROJECT_TYPE}}/${project_type//\//\\/}/g" "$file"
    sed -i "s/{{PROJECT_PURPOSE}}/${project_purpose//\//\\/}/g" "$file"
    sed -i "s/{{PRIVACY_PROFILE}}/${privacy_profile//\//\\/}/g" "$file"
    sed -i "s/{{PRIVACY_DESCRIPTION}}/${privacy_desc//\//\\/}/g" "$file"
    sed -i "s/{{CREATED_DATE}}/${created_date//\//\\/}/g" "$file"
    sed -i "s|{{NOTION_HUB_URL}}|${notion_hub_url//\//\\/}|g" "$file"
    sed -i "s/{{NOTION_HUB_TITLE}}/${notion_hub_title//\//\\/}/g" "$file"
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
  [[ ! -f "${dir}/AGENTS.md" || ! -f "${dir}/docs/runbook.md" ]]
}
