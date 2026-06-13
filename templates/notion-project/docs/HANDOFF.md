# HANDOFF — {{PROJECT_NAME}}

## 5 分钟路径

1. 读 `README.md`
2. 读 `docs/notion-sync-policy.md`
3. 打开 `manifest.yaml`
4. 查 `NOTION_INDEX.md`
5. 查 `data/tasks-master.csv`

## 常见操作

| 用户请求 | 操作 |
|---|---|
| 勾选完成 | 改 Notion 状态 → 同步 CSV |
| 新增任务 | CSV + Notion 双写 → CHANGELOG |
| 改 SOP | 先 `content/` → 再 Notion 页面 |
| 改结构 | 先 `docs/` + manifest → 再 Notion |

## 会话结束检查清单

- [ ] `CHANGELOG.md` 追加一条
- [ ] `manifest.yaml` 的 `last_synced` 更新
- [ ] `NOTION_INDEX.md` 与 Notion 实际结构一致
- [ ] CSV 状态与 Notion 一致（若改过状态）
