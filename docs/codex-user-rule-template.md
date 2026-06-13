# Codex 用户级规则模板

将下方「可复制正文」整段粘贴到 **Codex 用户规则**（User Rules / Instructions）中。

每台使用 Codex 的设备各配置 **一次** 即可，之后所有 ide-toolbox 项目自动受益。

---

## 配置位置（按你当前 Codex 界面查找）

在 Codex 设置里找到类似名称的入口：

- **User Rules** / **用户规则**
- **Instructions** / **自定义指令**
- **Global rules** / **全局规则**

将下方正文粘贴保存。若 Codex 与 Cursor 共用规则入口，可与 Cursor 用户规则合并；**不要**与项目内 `AGENTS.md` 重复维护项目专属内容。

---

## 可复制正文（开始）

```text
# 多端项目 Agent 总管规则（Codex 用户级 · ide-toolbox）

适用：通过 ide-toolbox（./ide）创建或升级的业务项目。工具箱目录本身见该目录 AGENTS.md。

## 每次打开项目目录时

1. 先读 `AGENTS.md`
2. 再读 `docs/ai-context.md` 和 `docs/runbook.md`
3. 若存在 `docs/codex-handoff.md`、`docs/conversation-reuse.md`，按需阅读
4. Notion 维护项目另读：`manifest.yaml`、`NOTION_INDEX.md`、`docs/HANDOFF.md`

## 真相源与记忆

- 以项目内 Markdown 文件和 Git 为真相源
- 不要把聊天记录当作项目唯一记忆
- 重要结论必须写回项目文件（优先 `docs/ai-context.md`，或 `docs/YYYYMMDD-主题.md`）
- 会话结束前说明：改了什么、为什么、如何验证、如何回滚、建议 commit message

## 动手前

- 若项目有 Git：先执行 `git status --short --branch`
- 工作区不干净时，先向用户汇报未提交变更，再大规模修改

## 长跑 Agent（用户常全权放任执行）

1. 分阶段：计划 → 修改 → 验证 → 总结
2. 每阶段保持最小有用改动，不扩大需求边界
3. 不可逆操作不要放在无人值守阶段
4. 未验证前不得声称完成

## 必须确认后才能做

- 删除或覆盖重要文件
- 移动、归档目录
- 修改远程仓库、push
- 安装依赖、改系统配置、暴露端口、改权限
- 写入密钥、执行 sudo

## 隐私

- 尊重项目 `docs/ai-context.md` 中的 Privacy Profile
- `private-local` 项目禁止创建 GitHub 仓库或 push

## 输出

- 回答使用中文
- 解释清楚，避免过度术语

## 推荐口令（用户可能这样说）

- 「按长跑模式执行这个项目」→ 严格遵循 `docs/runbook.md`
- 「把当前对话沉淀成项目记忆」→ 更新 `docs/ai-context.md` 或新建 `docs/YYYYMMDD-*.md`
- 「按 AGENTS.md 执行」→ 以项目文件为准，少向用户重复询问路径与结构
```

## 可复制正文（结束）

---

## 配置后自检

在任意业务项目目录对 Codex 说：

```text
请先按 AGENTS.md 和 runbook 说明你将读取哪些文件，以及如何写回项目记忆。不要改代码。
```

期望 Codex 能列出 `AGENTS.md`、`docs/ai-context.md`、`docs/runbook.md`，并说明写回策略。

---

## 与 Cursor 的分工

| 层级 | Cursor | Codex |
|---|---|---|
| 项目级自动规则 | `.cursor/rules/*.mdc` | 无等价目录 → 靠本用户规则 + `AGENTS.md` |
| 项目记忆文件 | `AGENTS.md`、`docs/*` | 同左 |
| 用户级兜底 | 可选补充 | **本模板（推荐必配）** |
