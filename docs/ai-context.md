# AI Context — IDE Toolbox

## Purpose

Cursor/Codex 多端项目的**自动化工具箱**（治理层）：`./ide` 入口、项目模板、升级/体检/归档脚本，以及 **Agent Library 复利工厂**（query / promote / wire_agent_library）。

## Privacy Profile

- Profile: `automation`（工具箱自身）
- GitHub：public repo（`Gacenwinl/ide-toolbox`），不含业务项目敏感数据

## Current State（接手必读）

- **主线**：Agent 复利 Hub 已接入工厂（2026-06-14，`46ec400`）；稳定性收敛修复见后续 commit
- **新建业务项目**：自动获得 `docs/agent-library.md` + `docs/suggested-assets.md`（`private-local` 跳过）
- **Notion 项目**：`templates/notion-project` 已补齐 `docs/ai-context.md`、Agent Library 挂钩、session-handoff 规则；`upgrade-ai-project.sh` 可为旧 Notion 项目补缺
- **共享库**：`02_Resources Files/05_Agent-Library`（独立 Git，manifest 索引；MacBook 当前为 Synology Drive 同步路径）
- **种子资产**：`notion-project-handoff-agent-library` 已晋升；早期 `ide-toolbox-handoff`、`agent-library-usage` 需在当前同步库中重新补齐或确认 NAS 端同步状态
- **Agent CLI**：`scripts/agent-cli.sh` + `./agent` 包装；文档已全量同步（AGENTS、playbook、runbook、onboarding、maintenance、project-toolbox 规则）
- **自维护就绪**：关闭 Cursor IDE 后，在终端 `cd ide-toolbox && ./agent start .` 即可接手；详见 `docs/agent-cli-self-maintenance.md`
- **待另端验证**：Windows / Mac mini `check-device.sh`
- **待 commit**：本阶段全部改动尚未提交；`run --execute` 需先 commit 且 `allow_execute: true`

## Last Session

- Date: 2026-06-14
- Summary: 完成 Agent CLI 全链路：脚本/模板/菜单/安全策略 + 文档同步；用户可关闭 Cursor IDE，用 `./agent` 在终端维护 ide-toolbox
- **Next agent（终端）**：
  1. `cd ide-toolbox`
  2. `./agent start .`（只读接手，读 ai-context → followup → changelog）
  3. 改文件前 `./agent plan . "任务"`；收尾 `./agent milestone .`
  4. substantial 工作后更新本文件 + changelog + `session-handoff.sh .`
- **Next agent reads**: 本节 → `docs/agent-cli-self-maintenance.md` → `docs/20260614-ide-toolbox-followup.md` → `docs/changelog.md`

## Recent Decisions

1. **Hub ≠ 共享文件夹**：必须 manifest + 工厂钩子 + 晋升纪律；`private-local` 永不进 05
2. **业务项目自动挂钩**：`wire_agent_library()` 在 `new-ai-project.sh` 末尾
3. **工具箱自身不走模板**：维护后必须更新本文件 + changelog + followup（与业务项目同一纪律）
4. **会话结束**： substantial 工作后更新 `Current State` / `Last Session`，必要时 `capture-conversation.sh`
5. **收敛优先**：ide-toolbox 自身稳定性优先于继续扩展复利/Obsidian/Codex 功能；菜单、文档、dispatch 必须一致
6. **Codex/Obsidian 分层**：Codex 自定义指令只做 L3 兜底；Obsidian 只做同一批 Markdown 的阅读界面，项目文件和 05 manifest 仍是真相源
7. **Notion 项目不例外**：Notion 双轨也必须有 ai-context / Last Session / suggested-assets；Notion 是执行层，本地文件仍是 AI 接手真相源
8. **CLI 是执行层，不是治理层**：Cursor Agent CLI 由 ide-toolbox 调用；隐私、复利、health、handoff 仍由 ide-toolbox 负责

## Open Items

- [ ] Windows / Mac mini 各跑一次 `check-device.sh`
- [ ] 旧活动项目：`batch-upgrade.sh --execute` 补齐 ai-context 与 agent-library 挂钩（含 Notion 项目）
- [ ] NAS 物理整理（04 迁出等）仍在 `260613-nas-storage-optimize`，非本仓库职责

## Source Of Truth

| 文件 | 用途 |
|---|---|
| `AGENTS.md` | Agent 入口与会话结束清单 |
| `README.md` / `README.html` | 人类总览 |
| `storage-policy.md` | 多端路径 + 05 Agent Library |
| `docs/runbook.md` | 维护长跑与安全 |
| `config/project-policy.yaml` | 路径、设备、`agent_library.*` |
| `projects-index.md` | 业务项目台账 |
| `docs/changelog.md` | 工具箱变更记录 |
| `docs/agent-cli-self-maintenance.md` | 关闭 Cursor IDE 后的终端自维护指南 |
| `docs/20260614-ide-toolbox-followup.md` | 多轮改造跟进 |
| `05_Agent-Library/manifest.yaml` | 跨项目资产索引（库内 Git） |

### Agent Library 脚本

| 脚本 | 用途 |
|---|---|
| `init-agent-library.sh` | 初始化 05 骨架 |
| `query-agent-assets.sh` | 按 manifest 匹配资产 |
| `promote-agent-asset.sh` | 晋升到 05 + manifest |
| `session-handoff.sh` | 会话收尾清单 + 提醒更新本文件 |
| `agent-cli.sh` | 调用 Cursor Agent CLI 的自动驾驶入口 |
| `agent-cli-prompt.py` | 组装标准 Agent prompt |

## 与业务项目模板的差异

工具箱**不是** `templates/ai-project` 的副本，但遵循同一原则：

- 项目文件为记忆真相源（**禁止只依赖聊天**）
- `.cursor/rules/project-toolbox.mdc` 等同业务项目的 `.cursor/rules`
- 维护后同步 `ai-context.md`（本节 Current State / Last Session）

## Handoff Checklist

维护工具箱后**必须**：

- [x] 更新 `docs/changelog.md`
- [x] 同步 `automation-playbook.md` / `docs/scripts-reference.md` / `AGENTS.md` / `docs/runbook.md` / `docs/onboarding.md` / `docs/maintenance.md`
- [x] 若影响总览，同步 `README.md` / `README.html`（Agent CLI 一节）
- [x] 多轮收尾写 `docs/YYYYMMDD-*-followup.md`
- [x] 更新本文件 `Current State` + `Last Session`
- [ ] substantial 对话后运行 `./scripts/session-handoff.sh .` 或 `capture-conversation.sh`
- [ ] `bash -n scripts/*.sh`（收尾验证）
- [x] 说明验证与回滚（中文）

## 关联项目

- **NAS 结构优化**：`260613-nas-storage-optimize`
- **跟进沉淀**：`docs/20260614-ide-toolbox-followup.md`
- **实施 capture**：`docs/20260614-agent-library-implementation.md`（及同日前缀 capture 文件）
