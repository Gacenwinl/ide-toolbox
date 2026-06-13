# AI Context — IDE Toolbox

## Purpose

Cursor/Codex 多端项目的**自动化工具箱**（治理层）：`./ide` 入口、项目模板、升级/体检/归档脚本，以及 **Agent Library 复利工厂**（query / promote / wire_agent_library）。

## Privacy Profile

- Profile: `automation`（工具箱自身）
- GitHub：public repo（`Gacenwinl/ide-toolbox`），不含业务项目敏感数据

## Current State（接手必读）

- **主线**：Agent 复利 Hub 已接入工厂（2026-06-14，`46ec400`）
- **新建业务项目**：自动获得 `docs/agent-library.md` + `docs/suggested-assets.md`（`private-local` 跳过）
- **共享库**：`02_Resources Files/05_Agent-Library`（独立 Git，manifest 索引）
- **种子资产**：`ide-toolbox-handoff`、`agent-library-usage`（playbooks）
- **待另端验证**：Windows / Mac mini `check-device.sh`

## Last Session

- Date: 2026-06-14
- Summary: 复利工厂接线完成；补齐移交记忆；新增 session-handoff 防新建项目再遗漏
- Next agent reads: 本节 → `docs/20260614-ide-toolbox-followup.md` → `docs/changelog.md`（2026-06-14 条目）

## Recent Decisions

1. **Hub ≠ 共享文件夹**：必须 manifest + 工厂钩子 + 晋升纪律；`private-local` 永不进 05
2. **业务项目自动挂钩**：`wire_agent_library()` 在 `new-ai-project.sh` 末尾
3. **工具箱自身不走模板**：维护后必须更新本文件 + changelog + followup（与业务项目同一纪律）
4. **会话结束**： substantial 工作后更新 `Current State` / `Last Session`，必要时 `capture-conversation.sh`

## Open Items

- [ ] Windows / Mac mini 各跑一次 `check-device.sh`
- [ ] 旧活动项目：`batch-upgrade.sh --execute` 补齐 agent-library 挂钩
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
| `docs/20260614-ide-toolbox-followup.md` | 多轮改造跟进 |
| `05_Agent-Library/manifest.yaml` | 跨项目资产索引（库内 Git） |

### Agent Library 脚本

| 脚本 | 用途 |
|---|---|
| `init-agent-library.sh` | 初始化 05 骨架 |
| `query-agent-assets.sh` | 按 manifest 匹配资产 |
| `promote-agent-asset.sh` | 晋升到 05 + manifest |
| `session-handoff.sh` | 会话收尾清单 + 提醒更新本文件 |

## 与业务项目模板的差异

工具箱**不是** `templates/ai-project` 的副本，但遵循同一原则：

- 项目文件为记忆真相源（**禁止只依赖聊天**）
- `.cursor/rules/project-toolbox.mdc` 等同业务项目的 `.cursor/rules`
- 维护后同步 `ai-context.md`（本节 Current State / Last Session）

## Handoff Checklist

维护工具箱后**必须**：

- [x] 更新 `docs/changelog.md`
- [x] 同步 `automation-playbook.md` / `docs/scripts-reference.md`
- [ ] 若影响总览，同步 `README.md` / `README.html`（复利一节已加）
- [x] 多轮收尾写 `docs/YYYYMMDD-*-followup.md`
- [x] 更新本文件 `Current State` + `Last Session`
- [ ] substantial 对话后运行 `./scripts/session-handoff.sh .` 或 `capture-conversation.sh`
- [ ] `bash -n scripts/*.sh`
- [ ] 说明验证与回滚（中文）

## 关联项目

- **NAS 结构优化**：`260613-nas-storage-optimize`
- **跟进沉淀**：`docs/20260614-ide-toolbox-followup.md`
- **实施 capture**：`docs/20260614-agent-library-implementation.md`（及同日前缀 capture 文件）
