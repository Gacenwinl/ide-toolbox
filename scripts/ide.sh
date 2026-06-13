#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

TARGET_PATH=""
if [[ $# -gt 0 ]]; then
  TARGET_PATH="$(normalize_dragged_path "$*")"
fi

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
  print_recent_projects
  local choice
  read -r -p "选择最近项目编号: " choice
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
action_change_path() { prompt_path; }

show_main_menu() {
  print_header
  printf '\n最近活动项目:\n'
  print_recent_projects
  cat <<'EOF'

主菜单:
  1) 从最近项目选择
  2) 新建多端 AI 项目
  3) 新建 Notion 维护项目
  4) 项目体检
  5) 升级已有目录
  6) 沉淀对话记忆
  7) 登记当前设备到项目
  8) 扫描并升级旧项目 (dry-run)
  9) 设备接入检查
  10) 检查 GitHub 就绪情况
  11) 归档预览
  12) 归档执行
  13) 查看项目索引
  14) 查看存储策略
  15) 更换目标路径
  0) 退出
EOF
}

show_path_menu() {
  print_header
  cat <<'EOF'

项目操作:
  1) 项目体检
  2) 升级成 Cursor/Codex 多端项目
  3) 沉淀对话记忆
  4) 登记当前设备
  5) 检查 Git 状态
  6) 检查 GitHub 就绪情况
  7) 归档预览 (dry-run)
  8) 归档执行
  9) 更换目标路径
  10) 返回主菜单
  0) 退出
EOF
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
    15) action_change_path ;;
    0|q|Q) exit 0 ;;
    *) warn "无效选项: $1" ;;
  esac
}

run_path_choice() {
  case "$1" in
    1) action_health ;;
    2) action_upgrade ;;
    3) action_capture ;;
    4) action_register_device ;;
    5) action_git_status ;;
    6) action_github_check ;;
    7) action_archive_preview ;;
    8) action_archive_execute ;;
    9) action_change_path ;;
    10) return 2 ;;
    0|q|Q) exit 0 ;;
    *) warn "无效选项: $1" ;;
  esac
}

main_loop() {
  while true; do
    if [[ -n "$TARGET_PATH" && -d "$TARGET_PATH" ]]; then
      show_path_menu
      read -r -p $'请输入数字: ' choice
      run_path_choice "$choice"
    else
      show_main_menu
      read -r -p $'请输入数字: ' choice
      run_main_choice "$choice"
    fi
    rc=$?
    if [[ "$rc" -eq 2 ]]; then
      TARGET_PATH=""
      continue
    elif [[ "$rc" -eq 0 ]]; then
      pause
    fi
  done
}

main_loop
