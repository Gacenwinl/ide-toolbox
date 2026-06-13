# AGENTS.md — {{PROJECT_NAME}}

## 角色

本地 + Notion 双轨维护项目。Notion 负责日常执行，本地负责结构、SOP、AI 接手。

## 会话启动

1. `README.md`
2. `docs/HANDOFF.md`
3. `docs/notion-sync-policy.md`
4. `manifest.yaml`
5. `NOTION_INDEX.md`
6. 相关 `data/*.csv`

## 总管规则

- 结构变更：先改 `docs/` + `manifest.yaml`，再改 Notion
- 长文 SOP：先改 `content/`，再同步 Notion 页面
- 任务状态：以 Notion 为准，回写 CSV
- 每次维护追加 `CHANGELOG.md`
- 可使用 Cursor Notion MCP，但本地 manifest 仍是映射真相源

## 隐私

- Profile: `{{PRIVACY_PROFILE}}`
- {{PRIVACY_DESCRIPTION}}
