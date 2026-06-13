# Conversation Capture — IDE Toolbox 跟进沉淀

Captured at: 2026-06-14

## Goal

收口 ide-toolbox 多轮改造，并落地 Agent Library 复利工厂接线。

## Status（2026-06-14 更新）

### 已完成

- [x] Agent Library 脚本：init / query / promote + `agent-library.py`
- [x] 工厂接线：new-ai-project `wire_agent_library`、upgrade、health、ide 菜单、capture 模板
- [x] 模板：agent-library.md、suggested-assets.md、AGENTS/rules/conversation-reuse 更新
- [x] `docs/devices.md` MacBook CloudStorage 路径登记（2026-06-14）
- [x] `config/project-policy.yaml` agent_library 路径与开关
- [x] 文档：scripts-reference、automation-playbook、changelog、codex 用户规则

### 待本机验证

- [ ] `git push` ide-toolbox（commit 后）
- [ ] MacBook `./scripts/check-device.sh`
- [ ] Windows / Mac mini `check-device.sh`（另端）
- [ ] `./ide` → 新建测试项目，检查 `docs/suggested-assets.md`

### 分工（不变）

| 主题 | 归属 |
|---|---|
| ide-toolbox 脚本/模板/菜单 | `ide-toolbox` |
| 05 种子资产内容与 manifest entries | `05_Agent-Library` Git |
| NAS 备份迁出、`04` 整理 | `260613-nas-storage-optimize` / 用户 |

## Suggested Commit Message

`feat(ide): wire agent library into new/upgrade/health/ide; query and promote scripts`
