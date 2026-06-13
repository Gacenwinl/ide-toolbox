# AGENTS.md — {{PROJECT_NAME}}

## 会话启动

1. `README.md`
2. `docs/ai-context.md`
3. `docs/runbook.md`
4. 按任务追加读取项目内相关文件

## 项目目标

{{PROJECT_PURPOSE}}

## 总管规则

- 先判定任务阶段，再动手修改。
- 信息不足时先查本目录；仍不足再问用户。
- 所有对外结果必须经过安全与事实检查。
- 重要结论写回项目文件，不依赖聊天记录作为唯一记忆。

## 多端交接

- Cursor 项目级规则：`.cursor/rules/ai-agent-workflow.mdc`
- 共享上下文：`docs/ai-context.md`
- 对话逻辑复用：`docs/conversation-reuse.md`
- 长跑与恢复：`docs/runbook.md`
