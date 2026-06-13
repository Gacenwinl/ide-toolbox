#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

DRY_RUN=false
YES=false

usage() {
  cat <<'EOF'
用法:
  ./scripts/init-agent-library.sh [--dry-run] [--yes]

说明:
  创建 05_Agent-Library 最小骨架（README、manifest、子目录、git init）。
  若目录已存在，仅补齐缺失项，不覆盖 manifest 已有 entries。
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true; shift ;;
    --yes) YES=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) die "未知参数: $1" ;;
  esac
done

LIB_DIR="$(resolve_agent_library_dir 2>/dev/null || read_policy_value agent_library "/Volumes/home/Drive/02_Resources Files/05_Agent-Library")"
MANIFEST_NAME="$(read_agent_library_policy_value manifest "manifest.yaml")"
MANIFEST_PATH="${LIB_DIR}/${MANIFEST_NAME}"

log "Agent Library 目标: $LIB_DIR"

if [[ "$DRY_RUN" == "true" ]]; then
  log "[dry-run] 将确保目录与子目录存在"
  log "[dry-run] manifest: $MANIFEST_PATH"
  exit 0
fi

mkdir -p "${LIB_DIR}/skills" "${LIB_DIR}/playbooks" "${LIB_DIR}/templates" "${LIB_DIR}/scripts" "${LIB_DIR}/rules"

if [[ ! -f "${LIB_DIR}/README.md" ]]; then
  cat > "${LIB_DIR}/README.md" <<'EOF'
# 05_Agent-Library — 跨项目 Agent 资产库

## 放什么

- 已在第二个不同项目中证明有用的 Skill、playbook、模板、规则片段

## 不放什么

- private-local 项目产出
- 密钥、证件、个人敏感信息

## 关联

- 索引真相源：`manifest.yaml`
- 工具箱：`ide-toolbox`（query / promote 脚本）
EOF
  log "已创建 README.md"
fi

if [[ ! -f "$MANIFEST_PATH" ]]; then
  cat > "$MANIFEST_PATH" <<'EOF'
# 05_Agent-Library 资产清单
version: "1.0"
updated: "2026-06-14"

library:
  path: "02_Resources Files/05_Agent-Library"
  purpose: "跨项目可复用的 Agent 资产"

promotion:
  rule: "同一产出在第二个不同项目中证明有用后才晋升"
  exclude:
    - "private-local 项目产出"
    - "含密钥、证件、个人敏感信息的文件"

categories:
  skills: skills/
  playbooks: playbooks/
  templates: templates/
  scripts: scripts/
  rules: rules/

entries: []
EOF
  log "已创建 manifest.yaml"
fi

if [[ ! -f "${LIB_DIR}/.gitignore" ]]; then
  cat > "${LIB_DIR}/.gitignore" <<'EOF'
.DS_Store
.env
.env.*
*.pem
*.key
*secret*
*credential*
EOF
  log "已创建 .gitignore"
fi

if [[ ! -d "${LIB_DIR}/.git" ]]; then
  require_command git
  (
    cd "$LIB_DIR"
    git init -q
    git add README.md manifest.yaml .gitignore skills playbooks templates scripts rules 2>/dev/null || true
    if git diff --cached --quiet; then
      log "Git 仓库已初始化（无待提交文件）"
    else
      git commit -m "chore: initialize Agent Library scaffold"
      log "已在 05_Agent-Library 完成初始 commit"
    fi
  )
else
  log "Git 仓库已存在，跳过 git init"
fi

log "Agent Library 就绪: $LIB_DIR"
