# {{PROJECT_NAME}}

{{PROJECT_PURPOSE}}

本地仓库 + Notion 双轨维护项目。

## AI 接手入口

1. [docs/HANDOFF.md](docs/HANDOFF.md)
2. [docs/notion-sync-policy.md](docs/notion-sync-policy.md)
3. [manifest.yaml](manifest.yaml)
4. [NOTION_INDEX.md](NOTION_INDEX.md)

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
```

## Notion Hub

{{NOTION_HUB_URL}}

完整映射见 `manifest.yaml`。
