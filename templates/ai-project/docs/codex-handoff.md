# Codex Handoff — {{PROJECT_NAME}}

本文件给 **Codex** 快速接手用。Cursor 用户主要读 `AGENTS.md` 和 `.cursor/rules/`；Codex 用户请配合 **用户级规则**（见工具箱 `docs/codex-user-rule-template.md`）。

## 每次会话先读

1. `AGENTS.md`
2. `docs/ai-context.md`
3. `docs/runbook.md`
4. 本文件

## 本项目目标

{{PROJECT_PURPOSE}}

## 写回规则

- 重要结论写入 `docs/ai-context.md` 或 `docs/YYYYMMDD-主题.md`
- 不依赖聊天记录作为唯一记忆
- 会话结束前说明：改了什么、如何验证、如何回滚

## 长跑口令

用户说「按长跑模式执行」时，严格遵循 `docs/runbook.md` 的分阶段与安全确认项。

## 工具箱

治理脚本在 `ide-toolbox` 目录，入口 `./ide`。本项目由该工具箱创建或升级时，已具备多端交接骨架。
