# AI Context — {{PROJECT_NAME}}

## Purpose

{{PROJECT_PURPOSE}}

## Privacy Profile

- Profile: `{{PRIVACY_PROFILE}}`
- Policy: {{PRIVACY_DESCRIPTION}}

## Current State（每次 substantial 工作后更新）

- 阶段：骨架创建
- 最近完成：由 ide-toolbox 创建 Notion 双轨项目
- 进行中：绑定 Notion Hub / 数据库 / 页面
- 阻塞/风险：Notion URL、data_source_id 仍可能待填写

## Last Session（会话结束必填）

- Date: (none yet)
- Summary: 待填写——上次 substantial 工作后写 1–3 句，让下一 Agent 无需翻聊天记录
- Next agent reads: `AGENTS.md` → 本节 → `docs/HANDOFF.md` → `manifest.yaml` → `NOTION_INDEX.md`

## Recent Decisions

- Notion 负责日常执行；本地负责结构、SOP、AI 接手与映射真相源
- 结构变更先改本地 `docs/`、`manifest.yaml`、`NOTION_INDEX.md`，再改 Notion
- 任务状态以 Notion 为准，CSV 只是镜像
- substantial 工作结束前必须更新本文件并运行 `session-handoff.sh`

## Open Items

- [ ] 填写 Notion Hub URL
- [ ] 填写 `manifest.yaml` 中的数据库 / 页面 URL
- [ ] 同步 `NOTION_INDEX.md`
- [ ] 首次运行 `python3 scripts/notion_hygiene.py verify`

## Source Of Truth

| 文件 | 用途 |
|---|---|
| `AGENTS.md` | 会话启动与会话结束规则 |
| `docs/ai-context.md` | 当前状态、Last Session、Recent Decisions |
| `docs/HANDOFF.md` | 5 分钟接手路径 |
| `docs/notion-sync-policy.md` | 本地/Notion 双轨规则 |
| `manifest.yaml` | 本地路径 ↔ Notion 映射真相源 |
| `NOTION_INDEX.md` | 人类可读 Notion 索引 |
| `data/*.csv` | 数据库镜像 |
| `content/` | 长文 SOP / 页面源稿 |
| `CHANGELOG.md` | 维护记录 |
| `docs/agent-library.md` | 共享资产库策略 |
| `docs/suggested-assets.md` | 推荐共享资产 |

## Notion Maintenance Checklist

每次改 Notion 结构后：

- [ ] 更新 `manifest.yaml`
- [ ] 更新 `NOTION_INDEX.md`
- [ ] 需要镜像时更新 `data/*.csv`
- [ ] 追加 `CHANGELOG.md`
- [ ] 更新本文件 Current State / Last Session
- [ ] 运行 `python3 scripts/notion_hygiene.py verify`
- [ ] 运行 ide-toolbox `session-handoff.sh`

## Agent Library Promotion

- 只晋升去敏后的 Notion 双轨 SOP、日历/打卡模式、manifest 模板
- 不晋升真实 Notion URL、data_source_id、个人计划、项目实例文件
- `private-local` 项目永不晋升
