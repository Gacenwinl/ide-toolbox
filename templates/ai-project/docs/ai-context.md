# AI Context — {{PROJECT_NAME}}

## Purpose

{{PROJECT_PURPOSE}}

## Privacy Profile

- Profile: `{{PRIVACY_PROFILE}}`
- Policy: {{PRIVACY_DESCRIPTION}}

## Current State（每次 substantial 工作后更新）

- 阶段：
- 最近完成：
- 进行中：
- 阻塞/风险：

## Last Session（会话结束必填）

- Date: (none yet)
- Summary: 待填写——上次 substantial 工作后写 1–3 句，让下一 Agent 无需翻聊天记录
- Next agent reads: `AGENTS.md` → 本节 → `Recent Decisions` → `docs/suggested-assets.md`（若非 private-local）

## Recent Decisions

- （尚无——有决策时追加，保留可复用规则）

## Open Items

- [ ] （创建后填写）

## Source Of Truth

| 文件 | 用途 |
|---|---|
| `AGENTS.md` | 会话启动与**会话结束**清单 |
| `README.md` | 人类总览 |
| `docs/runbook.md` | 长跑与安全 |
| `docs/agent-library.md` | 共享库策略与路径 |
| `docs/suggested-assets.md` | 新建时自动匹配的共享资产 |
| `docs/codex-handoff.md` | Codex 接手 |
| `docs/conversation-reuse.md` | 沉淀与晋升评估 |
| `docs/devices.md` | 设备台账 |
| `docs/YYYYMMDD-*.md` | 单次对话 capture（由 `capture-conversation.sh` 生成） |

## Cursor vs Codex

| Tool | How rules load |
|---|---|
| Cursor | `.cursor/rules/*.mdc` + this file |
| Codex | User-level rule + this file + `docs/codex-handoff.md` each session |

## Multi-Device Workflow

1. Open this project on the current device.
2. Read `AGENTS.md` first.
3. Check Git status before broad edits.
4. Write durable decisions back into this file (`Current State` / `Last Session`).

## Handoff Checklist（会话结束必做）

 substantial 工作结束前：

- [ ] 更新上方 **Current State** 与 **Last Session**（禁止留「待填写」）
- [ ] 重要决策写入 **Recent Decisions**
- [ ] 运行 ide-toolbox `session-handoff.sh` 或 `capture-conversation.sh`（二选一或都做）
- [ ] 说明：改了什么、为什么、如何验证、如何回滚、建议 commit message
- [ ] 评估是否晋升到 `05_Agent-Library`（见 `docs/conversation-reuse.md`）
