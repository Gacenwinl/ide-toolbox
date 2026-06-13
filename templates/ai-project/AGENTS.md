# AGENTS.md — {{PROJECT_NAME}}

## 会话启动

1. `README.md`
2. `docs/ai-context.md`
3. `docs/runbook.md`
4. `docs/agent-library.md`
5. 若非 `private-local`：读 `docs/suggested-assets.md`，按建议顺序阅读共享资产
6. 按任务追加读取项目内相关文件

## Agent Library（复利）

- 共享库路径见 `docs/agent-library.md`
- 任务开始前：运行 ide-toolbox `query-agent-assets.sh --task "<任务摘要>"` 或使用 `./ide` → 查询资产库
- 会话结束：评估是否将可复用产出晋升到 `05_Agent-Library`（见 `docs/conversation-reuse.md`）
- `private-local`：**禁止**读取或写入 `05_Agent-Library`

## 项目目标

{{PROJECT_PURPOSE}}

## 总管规则

- 先判定任务阶段，再动手修改。
- 信息不足时先查本目录；仍不足再问用户。
- 所有对外结果必须经过安全与事实检查。
- 重要结论写回项目文件，不依赖聊天记录作为唯一记忆。

## 多端交接

- Cursor 项目级规则：`.cursor/rules/ai-agent-workflow.mdc`
- Codex 用户级规则：见 ide-toolbox `docs/codex-user-rule-template.md`（每台设备配置一次）
- Codex 项目内入口：`docs/codex-handoff.md`
- 共享上下文：`docs/ai-context.md`
- 对话逻辑复用：`docs/conversation-reuse.md`
- 长跑与恢复：`docs/runbook.md`
