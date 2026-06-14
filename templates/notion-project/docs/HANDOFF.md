# HANDOFF — {{PROJECT_NAME}}

## 5 分钟路径

1. 读 `README.md`
2. 读 `docs/ai-context.md`
3. 读 `docs/notion-sync-policy.md`
4. 打开 `manifest.yaml`
5. 查 `NOTION_INDEX.md`
6. 查 `docs/suggested-assets.md`
7. 查 `data/tasks-master.csv`

**Codex 用户**：确保已配置 ide-toolbox `docs/codex-user-rule-template.md` 中的用户级规则；通用接手流程见该模板中的 Notion 条目。

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
- [ ] `docs/ai-context.md` 的 Current State / Last Session 已更新
- [ ] 已运行 ide-toolbox `session-handoff.sh`
- [ ] 若产生通用模式，已评估是否去敏后晋升到 Agent Library
