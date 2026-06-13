#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

profile="$(detect_device_profile)"
device_name="$(current_device_name)"

printf '\n========================================\n'
printf ' 设备接入检查\n'
printf '========================================\n\n'

check_ok() { printf '[OK] %s\n' "$1"; }
check_warn() { printf '[WARN] %s\n' "$1"; }

printf '设备名: %s\n' "$device_name"
printf '设备配置: %s\n' "$profile"
printf '系统: %s\n' "$(uname -s 2>/dev/null || echo unknown)"
printf 'Shell: %s\n' "${SHELL:-unknown}"
printf '\n'

if command -v git >/dev/null 2>&1; then
  check_ok "git 已安装: $(git --version)"
else
  check_warn "git 未安装"
fi

if command -v gh >/dev/null 2>&1; then
  check_ok "gh 已安装: $(gh --version | head -n1)"
  if gh auth status >/dev/null 2>&1; then
    check_ok "gh 已登录"
  else
    check_warn "gh 未登录，请执行: gh auth login"
  fi
else
  check_warn "gh 未安装，GitHub 自动创建不可用"
fi

check_path() {
  local label="$1"
  local path="$2"
  if [[ -d "$path" || -x "$path" ]]; then
    check_ok "${label} 可达: $path"
  else
    check_warn "${label} 不可达: $path"
  fi
}

check_path "活动目录" "$(read_device_policy_value "$profile" active_projects "$(read_policy_value active_projects)")"
check_path "归档目录" "$(read_policy_value archive_projects)"
check_path "工具箱目录" "$TOOLBOX_ROOT"
check_path "ide 入口" "${TOOLBOX_ROOT}/ide"

if [[ "$profile" == "windows" ]]; then
  win_path="$(read_device_policy_value windows active_projects "")"
  if [[ "$win_path" == "待填写 Windows 映射盘路径" ]]; then
    check_warn "请在 config/project-policy.yaml 填写 devices.windows.active_projects"
  fi
  check_ok "Windows 建议使用 Git Bash 运行 ./ide"
fi

if active_dir="$(resolve_active_dir 2>/dev/null)"; then
  check_ok "当前默认活动项目根目录: $active_dir"
else
  check_warn "无法解析活动项目根目录"
fi

echo '说明:'
echo '- 这是“当前设备环境自检”，不是 Git 被哪些设备 pull 过的列表。'
echo '- 项目级设备台账请使用 register-device.sh 或 ./ide 菜单登记。'
