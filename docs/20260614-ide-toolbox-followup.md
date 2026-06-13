# Conversation Capture — IDE Toolbox 跟进沉淀

Captured at: 2026-06-14

## Goal

收口 ide-toolbox 多轮改造，落地 Agent Library 复利工厂，并保证**工具箱自身可随时移交**（不依赖聊天）。

## Decision Logic

| 决策 | 规则 |
|---|---|
| Hub 形态 | 目录 + manifest + Git + ide-toolbox 工厂，不是单纯共享文件夹 |
| 自动挂钩 | `new-ai-project.sh` → `wire_agent_library()` → `suggested-assets.md` |
| private-local | 全链路跳过 05 |
| 工具箱记忆 | 与业务项目相同：更新 `ai-context.md` Current State / Last Session + changelog + followup |
| NAS 细整理 | 归 `260613-nas-storage-optimize`，本仓库不搬文件 |

## Status（2026-06-14 收口）

### 已完成

- [x] Agent Library：init / query / promote + `agent-library.py`
- [x] 工厂接线：new / upgrade / batch / health / ide / capture
- [x] 模板：agent-library、suggested-assets、AGENTS、rules、conversation-reuse
- [x] `config/project-policy.yaml`：`agent_library.*`
- [x] 05 库 Git + 2 条种子 playbook
- [x] ide-toolbox `git push` → `46ec400`
- [x] MacBook `check-device.sh` 通过
- [x] `docs/ai-context.md` 复利与接手状态已写回
- [x] `session-handoff.sh` + 业务项目模板会话结束纪律
- [x] 验证项目 `260614-agent-wire-test`（suggested-assets 有 2 条）
- [x] 稳定性收敛审计：菜单文档与主流程一致；修复备用 dispatch 映射；修复 `project-health.sh` 错误函数名

### 待另端 / 用户

- [ ] Windows `check-device.sh`
- [ ] Mac mini `check-device.sh`
- [ ] `batch-upgrade.sh --execute` 为旧项目补 agent-library

## Verification

```bash
cd ide-toolbox
./scripts/check-device.sh
./scripts/query-agent-assets.sh --task "ide-toolbox 接手"
./scripts/project-health.sh ../260614-agent-wire-test
./scripts/project-health.sh .
# 接手测试：只读 AGENTS.md + docs/ai-context.md，不应需要本聊天
```

## Rollback

- ide-toolbox：`git revert 46ec400` 或回退到 `78c1af9`
- 05 库：在 `05_Agent-Library` 内 `git log` 后 revert 对应 commit

## Suggested Commit Message

`docs(ide): complete handoff memory and session-handoff for all projects`

`fix(ide): align menu dispatch and health warning path`
