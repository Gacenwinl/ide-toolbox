# Codex 接入指南

目标：让 **Codex** 与 **Cursor** 在同一套 NAS/Git 项目上行为一致——**少重复交代，多写回项目文件**。

## 核心差异（30 秒理解）

| | Cursor | Codex |
|---|---|---|
| 项目打开后规则自动加载 | ✅ `.cursor/rules/*.mdc` | ❌ 无 `.codex/rules` |
| 项目记忆文件 | ✅ `AGENTS.md`、`docs/*` | ✅ 同左（需 Agent 主动读） |
| 推荐补齐方式 | 新建项目已自带 Cursor 规则 | **配置一次用户级规则** |

结论：**文件层两边完全共用；Codex 多配一条用户级规则，即可对齐 Cursor 的「开箱接手」体验。**

## 一次性配置（每台 Codex 设备做一次）

### 1. 复制用户规则

打开 [codex-user-rule-template.md](codex-user-rule-template.md)，将「可复制正文」整段粘贴到 Codex 的 **User Rules / 用户规则** 中并保存。

或在终端查看：

```bash
cd "/Volumes/home/Drive/00_FileStation/ide-toolbox"
sed -n '/## 可复制正文（开始）/,/## 可复制正文（结束）/p' docs/codex-user-rule-template.md
```

### 2. 确认能访问项目目录

与 Cursor 相同，任选其一：

- Mac NAS 挂载：`/Volumes/home/Drive/00_FileStation/...`
- Mac Drive 同步：`~/Library/CloudStorage/SynologyDrive-FileStation/...`
- Windows Git Bash：`C:/Users/13555/SynologyDrive/...`（Synology Drive 同步，见 `config/project-policy.yaml`）

详见 [storage-policy.md](../storage-policy.md#多端路径对照群晖--mac--windows)。

### 3. 自检

在任意已用 ide-toolbox 创建的项目里对 Codex 说：

```text
按 AGENTS.md 执行。先列出你将读取的文件，以及本次会话结束时会写回哪些文件。不要改代码。
```

通过标准：能提到 `AGENTS.md`、`docs/ai-context.md`、`docs/runbook.md`，并承诺写回项目 Markdown。

## 日常使用（与 Cursor 相同）

```bash
cd "/Volumes/home/Drive/00_FileStation/ide-toolbox"
./ide /path/to/your-project
```

推荐顺序：

1. 项目体检
2. 登记当前设备（写入 `docs/devices.md`）
3. 在 Codex 中打开**同一项目目录**
4. 直接说任务，例如：「按长跑模式执行这个项目」

**不必每次说明：** 项目路径、多端结构、NAS 策略——这些已在项目文件里。

## 项目内 Codex 专用文件

新建/升级后的业务项目包含 `docs/codex-handoff.md`，用更短的语言提醒 Codex 先读哪些文件。  
用户级规则负责「所有项目通用」；`codex-handoff.md` 负责「本项目补充」。

## 沉淀对话记忆

与 Cursor 相同：

```bash
./ide /path/to/project
# 3) 沉淀对话记忆（已选项目后的项目菜单）
```

或对 Codex 说：「把当前对话沉淀成项目记忆」。

## 常见问题

### Codex 没有读 AGENTS.md

1. 确认用户规则已按模板配置
2. 开场明确说：「按 AGENTS.md 执行」
3. 运行项目体检，确认 `AGENTS.md` 存在

### Codex 和 Cursor 结论不一致

以 **项目内 Git + Markdown 文件** 为准，不要把某一边聊天记录当权威。  
把最终决策写进 `docs/ai-context.md`。

### Notion 维护项目

除通用文件外，Codex 还需读：`manifest.yaml`、`NOTION_INDEX.md`、`docs/notion-sync-policy.md`。

## 相关文档

- [codex-user-rule-template.md](codex-user-rule-template.md) — 用户规则可复制正文
- [onboarding.md](onboarding.md) — 新设备接入（含 Windows）
- [automation-playbook.md](../automation-playbook.md) — `./ide` 日常操作
