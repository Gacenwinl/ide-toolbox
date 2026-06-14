# AI Runbook — IDE Toolbox

## Start A Session

1. `git status --short --branch`
2. `AGENTS.md` → `docs/ai-context.md`
3. 改脚本前读 `docs/scripts-reference.md`

## Safe Change Pattern

1. 说明影响范围（脚本 / 模板 / 文档）
2. 最小改动；`bash -n scripts/*.sh`
3. 更新 `docs/changelog.md`
4. 建议 commit message（中文）

## High-Risk Actions（需用户确认）

- 删除或覆盖脚本、模板
- `git push`、改 GitHub 可见性
- 移动/归档业务项目
- 自动安装依赖

## Agent CLI（关闭 Cursor IDE 后）

```bash
./agent start . --dry-run
./agent start .
./agent plan . "任务目标"
./agent milestone .
./agent run . "任务" --execute   # 需 allow_execute: true，且 Git 工作区干净
```

详见 [agent-cli-self-maintenance.md](agent-cli-self-maintenance.md)。

## 维护菜单/脚本后验证

```bash
bash -n scripts/*.sh
python3 -m py_compile scripts/agent-cli-prompt.py scripts/agent-library.py
./scripts/check-device.sh
./agent start . --dry-run
IDE_MENU_PLAIN=1 ./ide   # 非交互冒烟（输入 0 退出）
```

交互菜单请在**系统终端**或 Cursor 内置终端直接运行 `./ide` 验证 ↑↓ 与 `11`+回车（功能项）、`1`+回车（最近项目）。

## Rollback

```bash
git checkout -- <file>
```

## End A Session（ substantial 工作后）

1. 更新 `docs/ai-context.md` → **Current State** / **Last Session**
2. 更新 `docs/changelog.md`
3. `./scripts/session-handoff.sh .` 检查移交就绪
4. 中文总结：改动、验证、回滚、commit message
