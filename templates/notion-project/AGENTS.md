# AGENTS.md — {{PROJECT_NAME}}

## 角色

本地 + Notion 双轨维护项目。Notion 负责日常执行，本地负责结构、SOP、AI 接手。

## 会话启动

1. `README.md`
2. `docs/ai-context.md`
3. `docs/HANDOFF.md`
4. `docs/notion-sync-policy.md`
5. `manifest.yaml`
6. `NOTION_INDEX.md`
7. `docs/agent-library.md`
8. `docs/suggested-assets.md`（若非 `private-local`）
9. 相关 `data/*.csv`

## 总管规则

- 结构变更：先改 `docs/` + `manifest.yaml`，再改 Notion
- 长文 SOP：先改 `content/`，再同步 Notion 页面
- 任务状态：以 Notion 为准，回写 CSV
- 每次维护追加 `CHANGELOG.md`
- 可使用 Cursor Notion MCP，但本地 manifest 仍是映射真相源
- substantial 工作结束前必须更新 `docs/ai-context.md` 的 Current State / Last Session
- 里程碑或结束项目时运行 ide-toolbox `session-handoff.sh`
- 可复用模式先去敏评估，第二次跨项目仍需要时再晋升到 `05_Agent-Library`

## 长跑模式

用户要求“按长跑模式”时：

1. 先给计划，不要直接创建/修改 Notion 资源
2. 说明会改哪些本地文件、哪些 Notion 页面/数据库
3. 再执行、验证、写回 `docs/ai-context.md`

## 隐私

- Profile: `{{PRIVACY_PROFILE}}`
- {{PRIVACY_DESCRIPTION}}
