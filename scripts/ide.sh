#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

TARGET_PATH=""
if [[ $# -gt 0 ]]; then
  TARGET_PATH="$(normalize_dragged_path "$*")"
fi

MAIN_MENU_ITEMS=(
  "从最近项目选择"
  "新建多端 AI 项目"
  "新建 Notion 维护项目"
  "项目体检"
  "升级已有目录"
  "沉淀对话记忆"
  "会话收尾移交检查"
  "登记当前设备到项目"
  "扫描并升级旧项目 (dry-run)"
  "设备接入检查"
  "检查 GitHub 就绪情况"
  "归档预览"
  "归档执行"
  "查看项目索引"
  "查看存储策略"
  "查询 Agent 资产库"
  "晋升资产到库"
  "初始化 Agent Library"
  "更换目标路径"
  "Codex 接入与用户规则"
  "退出"
)

PATH_MENU_ITEMS=(
  "项目体检"
  "升级成 Cursor/Codex 多端项目"
  "沉淀对话记忆"
  "会话收尾移交检查"
  "登记当前设备"
  "刷新 suggested-assets"
  "晋升本项目资产到库"
  "检查 Git 状态"
  "检查 GitHub 就绪情况"
  "归档预览 (dry-run)"
  "归档执行"
  "更换目标路径"
  "返回主菜单"
  "退出"
)

print_header() {
  printf '\n========================================\n'
  printf ' IDE Toolbox\n'
  printf '========================================\n'
  printf '设备: %s (%s)\n' "$(current_device_name)" "$(detect_device_profile)"
  if [[ -n "$TARGET_PATH" && -d "$TARGET_PATH" ]]; then
    printf '当前项目: %s\n' "$(basename "$TARGET_PATH")"
    printf '路径: %s\n' "$TARGET_PATH"
  elif [[ -n "$TARGET_PATH" ]]; then
    printf '当前路径无效: %s\n' "$TARGET_PATH"
  else
    printf '当前项目: 未选择\n'
  fi
}

pause() { read -r -p $'\n按回车继续...' _; }

prompt_path() {
  local input
  read -r -p "请输入或拖入项目路径: " input
  TARGET_PATH="$(normalize_dragged_path "$input")"
  [[ -n "$TARGET_PATH" ]] || die "路径不能为空"
}

ensure_existing_path() {
  [[ -n "$TARGET_PATH" && -d "$TARGET_PATH" ]] || {
    prompt_path
    [[ -d "$TARGET_PATH" ]] || die "目录不存在: $TARGET_PATH"
  }
}

action_pick_recent_project() {
  list_recent_projects
  if [[ "${#RECENT_PROJECT_PATHS[@]}" -eq 0 ]]; then
    die "暂无最近活动项目"
  fi
  local labels=() choice
  local path
  for path in "${RECENT_PROJECT_PATHS[@]}"; do
    labels+=("$(basename "$path")")
  done
  choice="$(interactive_menu_select "最近活动项目:" "${labels[@]}")"
  [[ "$choice" == "0" ]] && return 0
  TARGET_PATH="$(select_recent_project "$choice")"
  log "已选择: $TARGET_PATH"
}

action_new_notion_project() {
  local name purpose hub_url hub_title
  read -r -p "项目名称 (如 260614-trip-prep): " name
  [[ -n "$name" ]] || die "项目名称不能为空"
  read -r -p "项目目标: " purpose
  purpose="${purpose:-待补充项目目标}"
  read -r -p "Notion Hub URL (可留空): " hub_url
  hub_url="${hub_url:-待填写}"
  read -r -p "Notion Hub 标题 (可留空，默认用项目名): " hub_title
  hub_title="${hub_title:-$name}"
  NOTION_HUB_URL="$hub_url" NOTION_HUB_TITLE="$hub_title" \
    "${SCRIPT_DIR}/new-ai-project.sh" "$name" \
      --type notion-sync --privacy knowledge --purpose "$purpose" --github none
}

action_new_project() {
  local name purpose ptype privacy github
  read -r -p "项目名称 (如 260614-my-project): " name
  [[ -n "$name" ]] || die "项目名称不能为空"
  read -r -p "项目目标: " purpose
  purpose="${purpose:-待补充项目目标}"
  printf '项目类型: 1) code  2) docs  3) knowledge  4) automation\n'
  read -r -p "选择 [1]: " ptype
  case "${ptype:-1}" in
    1|code|"") ptype="code" ;;
    2|docs) ptype="docs" ;;
    3|knowledge) ptype="knowledge" ;;
    4|automation) ptype="automation" ;;
    *) die "无效项目类型" ;;
  esac
  printf '隐私策略: 1) code  2) knowledge  3) private-local  4) automation\n'
  read -r -p "选择 [1]: " privacy
  case "${privacy:-1}" in
    1|code|"") privacy="code" ;;
    2|knowledge) privacy="knowledge" ;;
    3|private-local|private) privacy="private-local" ;;
    4|automation) privacy="automation" ;;
    *) die "无效隐私策略" ;;
  esac
  local args=(--type "$ptype" --privacy "$privacy" --purpose "$purpose")
  if privacy_profile_allows_github "$privacy"; then
    printf 'GitHub: 1) 不创建  2) private  3) private + push\n'
    read -r -p "选择 [1]: " github
    case "${github:-1}" in
      1|none|"") ;;
      2|private) args+=(--github private) ;;
      3|push) args+=(--github private --push) ;;
      *) die "无效 GitHub 选项" ;;
    esac
  else
    log "隐私策略 ${privacy} 禁止 GitHub，将仅创建本地项目"
  fi
  "${SCRIPT_DIR}/new-ai-project.sh" "$name" "${args[@]}"
}

action_health() { ensure_existing_path; "${SCRIPT_DIR}/project-health.sh" "$TARGET_PATH"; }
action_upgrade() { ensure_existing_path; "${SCRIPT_DIR}/upgrade-ai-project.sh" "$TARGET_PATH"; }
action_capture() {
  ensure_existing_path
  local title
  read -r -p "对话标题（可留空）: " title
  if [[ -n "$title" ]]; then
    "${SCRIPT_DIR}/capture-conversation.sh" "$TARGET_PATH" --title "$title"
  else
    "${SCRIPT_DIR}/capture-conversation.sh" "$TARGET_PATH"
  fi
}

action_session_handoff() {
  ensure_existing_path
  local summary
  read -r -p "Last Session 摘要（可留空，仅检查）: " summary
  if [[ -n "$summary" ]]; then
    "${SCRIPT_DIR}/session-handoff.sh" "$TARGET_PATH" --summary "$summary"
  else
    "${SCRIPT_DIR}/session-handoff.sh" "$TARGET_PATH"
  fi
}

action_register_device() {
  ensure_existing_path
  local note
  read -r -p "备注（可留空）: " note
  if [[ -n "$note" ]]; then
    "${SCRIPT_DIR}/register-device.sh" "$TARGET_PATH" --note "$note"
  else
    "${SCRIPT_DIR}/register-device.sh" "$TARGET_PATH"
  fi
}
action_batch_upgrade() { "${SCRIPT_DIR}/batch-upgrade.sh"; }
action_batch_upgrade_execute() {
  if confirm "确认批量升级所有缺少模板的项目？"; then
    "${SCRIPT_DIR}/batch-upgrade.sh" --execute
  fi
}
action_check_device() { "${SCRIPT_DIR}/check-device.sh"; }
action_git_status() {
  ensure_existing_path
  if [[ -d "${TARGET_PATH}/.git" ]]; then
    git -C "$TARGET_PATH" status --short --branch
  else
    warn "该目录尚未初始化 Git"
  fi
}
action_archive_preview() { ensure_existing_path; "${SCRIPT_DIR}/archive-project.sh" "$TARGET_PATH"; }
action_archive_execute() { ensure_existing_path; "${SCRIPT_DIR}/archive-project.sh" "$TARGET_PATH" --execute; }
action_github_check() {
  if command -v gh >/dev/null 2>&1; then
    log "GitHub CLI 已安装"
    gh auth status || warn "gh 尚未登录，请执行: gh auth login"
  else
    warn "未安装 GitHub CLI (gh)"
  fi
  if [[ -n "$TARGET_PATH" && -d "$TARGET_PATH" && -d "${TARGET_PATH}/.git" ]]; then
    git -C "$TARGET_PATH" remote -v 2>/dev/null || warn "未配置 remote"
  fi
}
action_show_index() { [[ -f "$INDEX_FILE" ]] && cat "$INDEX_FILE" || warn "项目索引不存在"; }
action_show_storage_policy() { cat "${TOOLBOX_ROOT}/storage-policy.md"; }

action_query_agent_library() {
  local task purpose ptype privacy
  read -r -p "任务关键词（可留空）: " task
  read -r -p "项目目标/用途（可留空）: " purpose
  read -r -p "项目类型 [code]: " ptype
  ptype="${ptype:-code}"
  read -r -p "隐私策略 [code]: " privacy
  privacy="${privacy:-code}"
  "${SCRIPT_DIR}/query-agent-assets.sh" --task "$task" --purpose "$purpose" --type "$ptype" --privacy "$privacy"
}

action_promote_agent_asset() {
  ensure_existing_path
  local source id title tags triggers
  read -r -p "源文件路径（项目内 markdown）: " source
  [[ -f "$source" ]] || die "文件不存在: $source"
  read -r -p "资产 ID (如 ide-toolbox-handoff): " id
  [[ -n "$id" ]] || die "ID 不能为空"
  read -r -p "标题: " title
  [[ -n "$title" ]] || die "标题不能为空"
  read -r -p "tags（逗号分隔，可留空）: " tags
  read -r -p "triggers（逗号分隔，可留空）: " triggers
  "${SCRIPT_DIR}/promote-agent-asset.sh" \
    --project "$TARGET_PATH" \
    --source "$source" \
    --id "$id" \
    --title "$title" \
    --tags "$tags" \
    --triggers "$triggers" \
    --project-types "code,docs,knowledge,automation" \
    --when-to-use "见 manifest 与源文件" \
    --source-project "$(basename "$TARGET_PATH")"
}

action_refresh_suggested_assets() {
  ensure_existing_path
  local purpose ptype privacy
  purpose="$(grep -m1 '^## 项目目标' -A2 "${TARGET_PATH}/docs/ai-context.md" 2>/dev/null | tail -n1 || echo "")"
  ptype="knowledge"
  privacy="code"
  if [[ -f "${TARGET_PATH}/docs/agent-library.md" ]] && grep -q "Privacy Profile: \`private-local\`" "${TARGET_PATH}/docs/agent-library.md"; then
    privacy="private-local"
  fi
  "${SCRIPT_DIR}/query-agent-assets.sh" \
    --purpose "$purpose" \
    --type "$ptype" \
    --privacy "$privacy" \
    --output "${TARGET_PATH}/docs/suggested-assets.md"
  log "已刷新 ${TARGET_PATH}/docs/suggested-assets.md"
}

action_init_agent_library() { "${SCRIPT_DIR}/init-agent-library.sh"; }

action_show_codex_setup() {
  cat "${TOOLBOX_ROOT}/docs/codex-onboarding.md"
  printf '\n========================================\n'
  printf ' 用户规则模板（复制到 Codex User Rules）\n'
  printf '========================================\n\n'
  sed -n '/^```text$/,/^```$/p' "${TOOLBOX_ROOT}/docs/codex-user-rule-template.md" | sed '1d;$d'
  printf '\n完整说明见: %s/docs/codex-user-rule-template.md\n' "$TOOLBOX_ROOT"
}
action_change_path() { prompt_path; }

show_main_menu() {
  print_header
}

show_path_menu() {
  print_header
}

build_home_menu_options() {
  HOME_MENU_OPTIONS=()
  list_recent_projects
  HOME_RECENT_COUNT="${#RECENT_PROJECT_PATHS[@]}"
  local path slot=1 func_slot=11 item
  for path in "${RECENT_PROJECT_PATHS[@]}"; do
    HOME_MENU_OPTIONS+=("[${slot}] 打开: $(basename "$path")")
    slot=$((slot + 1))
  done
  for item in "${MAIN_MENU_ITEMS[@]:1}"; do
    HOME_MENU_OPTIONS+=("[${func_slot}] ${item}")
    func_slot=$((func_slot + 1))
  done
}

home_menu_title() {
  printf '菜单 (1-10 快速打开最近项目 · 11+ 其他操作):'
}

dispatch_home_choice() {
  local choice main_idx
  build_home_menu_options
  [[ "${#HOME_MENU_OPTIONS[@]}" -gt 0 ]] || die "菜单为空"

  choice="$(interactive_menu_select "$(home_menu_title)" "${HOME_MENU_OPTIONS[@]}")"
  choice="$(sanitize_menu_choice "$choice")"
  [[ -n "$choice" ]] || { warn "无效选项（空）"; return 1; }
  [[ "$choice" != "0" ]] || exit 0

  if (( choice >= 1 && choice <= 10 )); then
    list_recent_projects
    if (( choice > ${#RECENT_PROJECT_PATHS[@]} )); then
      warn "编号 ${choice} 无对应项目（当前 ${#RECENT_PROJECT_PATHS[@]} 个一周内最近项目，快速打开为 1-10）"
      return 1
    fi
    TARGET_PATH="${RECENT_PROJECT_PATHS[$((choice - 1))]}"
    log "已打开: $TARGET_PATH"
    return 0
  fi

  main_idx=$((choice - 10 + 1))
  case "$main_idx" in
    2) action_new_project ;;
    3) action_new_notion_project ;;
    4) action_health ;;
    5) action_upgrade ;;
    6) action_capture ;;
    7) action_session_handoff ;;
    8) action_register_device ;;
    9) action_batch_upgrade ;;
    10) action_check_device ;;
    11) action_github_check ;;
    12) action_archive_preview ;;
    13) action_archive_execute ;;
    14) action_show_index ;;
    15) action_show_storage_policy ;;
    16) action_query_agent_library ;;
    17) action_promote_agent_asset ;;
    18) action_init_agent_library ;;
    19) action_change_path ;;
    20) action_show_codex_setup ;;
    21) exit 0 ;;
    *) warn "无效选项: $choice"; return 1 ;;
  esac
}

read_path_menu_choice() {
  interactive_menu_select "项目操作:" "${PATH_MENU_ITEMS[@]}"
}

run_main_choice() {
  case "$1" in
    1) action_pick_recent_project ;;
    2) action_new_project ;;
    3) action_new_notion_project ;;
    4) action_health ;;
    5) action_upgrade ;;
    6) action_capture ;;
    7) action_register_device ;;
    8) action_batch_upgrade ;;
    9) action_check_device ;;
    10) action_github_check ;;
    11) action_archive_preview ;;
    12) action_archive_execute ;;
    13) action_show_index ;;
    14) action_show_storage_policy ;;
    15) action_query_agent_library ;;
    16) action_promote_agent_asset ;;
    17) action_init_agent_library ;;
    18) action_change_path ;;
    19) action_show_codex_setup ;;
    20|0|q|Q) exit 0 ;;
    *) warn "无效选项: $1" ;;
  esac
}

run_path_choice() {
  case "$1" in
    1) action_health ;;
    2) action_upgrade ;;
    3) action_capture ;;
    4) action_session_handoff ;;
    5) action_register_device ;;
    6) action_refresh_suggested_assets ;;
    7) action_promote_agent_asset ;;
    8) action_git_status ;;
    9) action_github_check ;;
    10) action_archive_preview ;;
    11) action_archive_execute ;;
    12) action_change_path ;;
    13) return 2 ;;
    14|0|q|Q) exit 0 ;;
    *) warn "无效选项: $1" ;;
  esac
}

main_loop() {
  local choice rc=0
  while true; do
    if [[ -n "$TARGET_PATH" && -d "$TARGET_PATH" ]]; then
      show_path_menu
      choice="$(read_path_menu_choice)"
      run_path_choice "$choice"
      rc=$?
    else
      show_main_menu
      dispatch_home_choice
      rc=$?
      if [[ "$rc" -eq 1 ]]; then
        continue
      fi
    fi
    if [[ "$rc" -eq 2 ]]; then
      TARGET_PATH=""
      continue
    elif [[ "$rc" -eq 0 ]]; then
      pause
    fi
  done
}

main_loop
