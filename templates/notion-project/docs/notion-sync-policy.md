# Notion 同步规范 — {{PROJECT_NAME}}

## 双轨分工

| 维度 | 本地 | Notion |
|---|---|---|
| 定位 | 元数据、架构、AI 接手、SOP 源稿 | 日常执行、勾选、提醒 |
| 权威 | 结构、命名、映射 | 任务状态、完成日 |
| 镜像 | `data/*.csv` 关键字段 | 全量任务与视图 |

## 更新流程

1. **结构变更** → 先改 `docs/` + `manifest.yaml` + `NOTION_INDEX.md` → 再建/改 Notion
2. **长文 SOP** → 在 `content/` 编辑 → 同步到 Notion 页面
3. **任务增删** → 更新 CSV + Notion + `CHANGELOG.md`
4. **状态勾选** → 仅在 Notion 改 → 回写 CSV

## Notion 载体规则

- 可追踪任务 → Database 全页
- 分步 SOP → 富文本专题页
- Hub → 只放链接，不嵌大段重复正文

## 冲突处理

- 任务数不一致 → 以 Notion 为准对账，更新 CSV
- `manifest.yaml` 缺 URL → 用 Notion 搜索补全，不要重复建页
