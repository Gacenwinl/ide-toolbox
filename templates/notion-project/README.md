# {{PROJECT_NAME}}

{{PROJECT_PURPOSE}}

本地仓库 + Notion 双轨维护项目。

## AI 接手入口

1. [AGENTS.md](AGENTS.md)
2. [docs/ai-context.md](docs/ai-context.md)
3. [docs/HANDOFF.md](docs/HANDOFF.md)
4. [docs/notion-sync-policy.md](docs/notion-sync-policy.md)
5. [manifest.yaml](manifest.yaml)
6. [NOTION_INDEX.md](NOTION_INDEX.md)
7. [docs/suggested-assets.md](docs/suggested-assets.md)

## 双轨原则

| 维度 | 本地 | Notion |
|---|---|---|
| 结构/命名 | `docs/`、`manifest.yaml` | 页面/数据库结构 |
| 任务状态 | `data/*.csv` 镜像 | 以 Notion 为准 |
| 长文 SOP | `content/` | Notion 专题页 |

## 常用命令

```bash
./scripts/notion-check.sh
# 配置 NOTION_TOKEN 后可用更完整脚本
python3 scripts/notion_hygiene.py verify

# 里程碑 / 暂停 / 结束前
/path/to/ide-toolbox/scripts/session-handoff.sh .
```

## 日常流程

1. 开始前：让 AI 先按 `AGENTS.md` 接手，不直接改 Notion
2. 长跑任务：先给计划，再修改本地与 Notion
3. 里程碑：更新 `docs/ai-context.md`，运行 `session-handoff.sh`
4. 复利：只把去敏后的通用 Notion 模式晋升到 `05_Agent-Library`

## Notion Hub

{{NOTION_HUB_URL}}

完整映射见 `manifest.yaml`。
