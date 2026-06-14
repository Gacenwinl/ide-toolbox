# Agent CLI Plan

你正在通过 ide-toolbox 的 Agent CLI 为项目制定执行计划。

## 项目

- Project: `{{PROJECT_NAME}}`
- Path: `{{PROJECT_PATH}}`
- Type: `{{PROJECT_TYPE}}`
- Privacy: `{{PRIVACY_PROFILE}}`

## 任务目标

{{TASK}}

## 必须遵守

1. 只做计划，不修改文件。
2. 先读取 `AGENTS.md`、`docs/ai-context.md`，再看 `docs/suggested-assets.md`。
3. 如果是 Notion 项目，还要读取 `docs/HANDOFF.md`、`manifest.yaml`、`NOTION_INDEX.md`。
4. 计划必须列出影响范围、文件变更、验证方式、回滚方式。
5. 涉及删除、覆盖、权限、密钥、Git push、Notion 结构大改时，必须标记为需要用户确认。
6. 输出结尾给出建议 commit message。

## 项目上下文

{{PROJECT_CONTEXT}}

## Suggested Assets

{{SUGGESTED_ASSETS}}
