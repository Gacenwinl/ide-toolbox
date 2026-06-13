#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

TARGET_DIR="${1:-}"
[[ -n "$TARGET_DIR" ]] || die "用法: ./scripts/project-health.sh /path/to/project"

[[ -d "$TARGET_DIR" ]] || die "目录不存在: $TARGET_DIR"

printf '\n========================================\n'
printf ' 项目体检: %s\n' "$(basename "$TARGET_DIR")"
printf '========================================\n\n'

ok_count=0
warn_count=0

report_ok() {
  printf '[OK] %s\n' "$1"
  ok_count=$((ok_count + 1))
}

report_warn() {
  printf '[WARN] %s\n' "$1"
  warn_count=$((warn_count + 1))
}

report_ok "目录存在: $TARGET_DIR"

if [[ -d "${TARGET_DIR}/.git" ]]; then
  report_ok "已初始化 Git"
  if git -C "$TARGET_DIR" status --porcelain | grep -q .; then
    report_warn "Git 工作区不干净"
    git -C "$TARGET_DIR" status --short --branch
  else
    report_ok "Git 工作区干净"
  fi
  if git -C "$TARGET_DIR" remote get-url origin >/dev/null 2>&1; then
    report_ok "已配置 origin remote: $(git -C "$TARGET_DIR" remote get-url origin)"
  else
    report_warn "未配置 origin remote"
  fi
else
  report_warn "尚未初始化 Git"
fi

if is_toolbox_project "$TARGET_DIR"; then
  report_ok "识别为 IDE Toolbox 自身"
  for file in docs/ai-context.md docs/runbook.md docs/conversation-reuse.md docs/codex-handoff.md docs/devices.md config/project-policy.yaml ide projects-index.md; do
    if [[ -f "${TARGET_DIR}/${file}" ]]; then
      report_ok "存在 ${file}"
    else
      report_warn "缺少 ${file}"
    fi
  done
elif is_notion_project "$TARGET_DIR"; then
  report_ok "识别为 Notion 维护项目"
  for file in manifest.yaml NOTION_INDEX.md docs/notion-sync-policy.md docs/HANDOFF.md data/tasks-master.csv; do
    if [[ -f "${TARGET_DIR}/${file}" ]]; then
      report_ok "存在 ${file}"
    else
      report_warn "缺少 ${file}"
    fi
  done
  if [[ -x "${TARGET_DIR}/scripts/notion-check.sh" ]]; then
    report_ok "存在 scripts/notion-check.sh"
  else
    report_warn "缺少可执行 scripts/notion-check.sh"
  fi
  if grep -q 'notion_url: ""' "${TARGET_DIR}/manifest.yaml" 2>/dev/null; then
    report_warn "manifest.yaml 中仍有未填写的 notion_url"
  fi
  if [[ -f "${TARGET_DIR}/.env" ]]; then
    report_warn "存在 .env，请勿提交到 Git"
  elif [[ -f "${TARGET_DIR}/.env.example" ]]; then
    report_ok "存在 .env.example（未配置 .env）"
  fi
else
  privacy_profile="code"
  if [[ -f "${TARGET_DIR}/docs/agent-library.md" ]] && grep -q "Privacy Profile: \`private-local\`" "${TARGET_DIR}/docs/agent-library.md"; then
    privacy_profile="private-local"
  fi
  for file in AGENTS.md docs/ai-context.md docs/runbook.md docs/conversation-reuse.md docs/codex-handoff.md docs/devices.md docs/agent-library.md; do
    if [[ -f "${TARGET_DIR}/${file}" ]]; then
      report_ok "存在 ${file}"
    else
      report_warn "缺少 ${file}"
    fi
  done
  if [[ "$privacy_profile" == "private-local" ]]; then
    report_ok "private-local：已正确跳过 Agent Library 共享库"
  elif [[ -f "${TARGET_DIR}/docs/suggested-assets.md" ]]; then
    report_ok "存在 docs/suggested-assets.md"
  else
    report_warn "缺少 docs/suggested-assets.md"
  fi
  if lib_dir="$(resolve_agent_library_dir 2>/dev/null)"; then
    report_ok "05_Agent-Library 可达: $lib_dir"
    manifest="${lib_dir}/$(read_agent_library_policy_value manifest manifest.yaml)"
    if [[ -f "$manifest" ]]; then
      sample_path="$(awk '/^  - id:/{found=1} found && /^    path:/{sub(/^    path: /,""); gsub(/"/,""); print; exit}' "$manifest" 2>/dev/null || true)"
      if [[ -n "$sample_path" && -f "${lib_dir}/${sample_path}" ]]; then
        report_ok "manifest 抽样路径有效: ${sample_path}"
      elif [[ -n "$sample_path" ]]; then
        report_warn "manifest 抽样路径不存在: ${sample_path}"
      else
        report_ok "manifest 尚无 entries（可后续晋升种子资产）"
      fi
    else
      report_warn "缺少 manifest: $manifest"
    fi
  else
    handoff_warn "05_Agent-Library 不可达（可运行 init-agent-library.sh）"
  fi
  if [[ -f "${TARGET_DIR}/docs/ai-context.md" ]]; then
    if grep -q "待填写" "${TARGET_DIR}/docs/ai-context.md" 2>/dev/null; then
      report_warn "ai-context 含「待填写」——会话结束应运行 session-handoff.sh"
    else
      report_ok "ai-context 无待填写占位（移交友好）"
    fi
    if grep -q "^- Date: (none yet)" "${TARGET_DIR}/docs/ai-context.md" 2>/dev/null; then
      report_warn "Last Session 未更新——接手者不知上次做到哪"
    else
      report_ok "Last Session 已记录日期"
    fi
  fi
fi

if [[ -d "${TARGET_DIR}/.cursor/rules" ]] && find "${TARGET_DIR}/.cursor/rules" -name '*.mdc' | grep -q .; then
  report_ok "存在 Cursor 项目规则"
else
  report_warn "缺少 .cursor/rules/*.mdc"
fi

if check_sensitive_files "$TARGET_DIR"; then
  report_ok "未检测到常见敏感文件模式"
else
  report_warn "检测到疑似敏感文件，提交前请确认"
fi

if command -v gh >/dev/null 2>&1; then
  if gh auth status >/dev/null 2>&1; then
    report_ok "GitHub CLI 已安装且已登录"
  else
    report_warn "GitHub CLI 已安装，但未登录"
  fi
else
  report_warn "未安装 GitHub CLI (gh)"
fi

if stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$TARGET_DIR" >/dev/null 2>&1; then
  report_ok "最近修改时间: $(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$TARGET_DIR")"
else
  report_ok "最近修改时间: $(stat -c "%y" "$TARGET_DIR" | cut -d. -f1)"
fi

printf '\n总结: OK=%d, WARN=%d\n' "$ok_count" "$warn_count"
if [[ "$warn_count" -gt 0 ]]; then
  printf '建议: 长跑 Agent 前先处理 WARN 项，或运行升级脚本补齐模板。\n'
else
  printf '状态良好，可以开始长跑 Agent 任务。\n'
fi
