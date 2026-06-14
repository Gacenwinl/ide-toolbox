# 脚本参考

所有脚本位于 `scripts/`。日常优先用 `./ide`，本节供查阅和自动化调用。

## 总览

| 脚本 | 用途 | 默认风险 | 会改文件 |
|---|---|---|---|
| `ide.sh` | 单一交互入口 | 低 | 视子命令 |
| `new-ai-project.sh` | 新建项目 | 中 | 是 |
| `upgrade-ai-project.sh` | 升级已有项目 | 低 | 仅补缺失 |
| `batch-upgrade.sh` | 批量升级 | 中 | `--execute` 时 |
| `project-health.sh` | 项目体检 | 无 | 否 |
| `check-device.sh` | 设备接入检查 | 无 | 否 |
| `register-device.sh` | 项目设备登记 | 低 | 是 |
| `capture-conversation.sh` | 对话沉淀模板 | 低 | 是 |
| `archive-project.sh` | 项目归档 | 高 | `--execute` 时 |
| `init-agent-library.sh` | 初始化 05_Agent-Library | 低 | 是 |
| `query-agent-assets.sh` | 查询共享资产 | 无 | `--output` 时 |
| `promote-agent-asset.sh` | 晋升资产到库 | 中 | 是 |
| `session-handoff.sh` | 会话收尾移交检查 | 无 | `--summary` 时 |
| `agent-cli.sh` | Cursor Agent CLI 自动驾驶入口 | 中 | `run --execute` 时 |
| `agent-cli-prompt.py` | 生成 Agent CLI prompt | 无 | 否 |
| `agent-library.py` | manifest 解析/匹配 | — | promote 时 |
| `lib.sh` | 公共函数库 | — | 否 |

风险级别：

- **无**：只读检查
- **低**：新增文件，不覆盖重要内容
- **中**：创建项目、Git init/commit、批量补文件
- **高**：移动目录、GitHub push、归档

---

## ide.sh / ide

```bash
./ide
./ide /path/to/project
```

交互式菜单，无 `--help`。

主菜单为**合一列表**：编号 **1–10** 快速打开最近项目（最多 5 个、一周内活动），**11+** 为新建/体检等操作。`0` 退出。

活动项目目录由 `resolve_active_dir` 解析：优先 `devices.<profile>.active_projects`（MacBook/Windows=Drive 同步，Mac mini=NAS 挂载）。详见 [storage-policy.md](../storage-policy.md)。

最近项目筛选见 `config/project-policy.yaml` → `recent_projects`（`limit: 5`、`max_age_days: 7`）。

**操作：** ↑↓/jk 移动 · 回车确认 · 数字+回车跳转（如 `11`+回车）。强制纯数字：`IDE_MENU_PLAIN=1 ./ide`

### 主菜单

| 编号 | 动作 |
|---|---|
| 1–10 | 快速打开最近项目（无项目时友好提示） |
| 11 | 新建多端 AI 项目 |
| 12 | 新建 Notion 维护项目 |
| 13 | 项目体检 |
| 14 | 升级已有目录 |
| 15 | 沉淀对话记忆 |
| 16 | 会话收尾移交检查 |
| 17 | 登记当前设备到项目 |
| 18 | 扫描并升级旧项目 (dry-run) |
| 19 | 设备接入检查 |
| 20 | 检查 GitHub 就绪情况 |
| 21 | 归档预览 |
| 22 | 归档执行 |
| 23 | 查看项目索引 |
| 24 | 查看存储策略 |
| 25 | 查询 Agent 资产库 |
| 26 | 晋升资产到库 |
| 27 | 初始化 Agent Library |
| 28 | 更换目标路径 |
| 29 | Agent CLI 自动驾驶 |
| 30 | Codex 接入与用户规则 |
| 31 | 退出 |

### 项目菜单（已选路径后）

| 编号 | 动作 |
|---|---|
| 1 | 项目体检 |
| 2 | 升级 |
| 3 | 沉淀对话记忆 |
| 4 | 会话收尾移交检查 |
| 5 | 登记当前设备 |
| 6 | 刷新 suggested-assets |
| 7 | 晋升本项目资产到库 |
| 8 | Git 状态 |
| 9 | GitHub 检查 |
| 10 | Agent CLI 自动驾驶 |
| 11 | 归档预览 |
| 12 | 归档执行 |
| 13 | 更换路径 |
| 14 | 返回主菜单 |
| 15 | 退出 |

---

## new-ai-project.sh

```bash
./scripts/new-ai-project.sh PROJECT_NAME [options]
```

### 参数

| 参数 | 说明 | 默认 |
|---|---|---|
| `--type` | `code` `docs` `knowledge` `automation` `notion-sync` | `code` |
| `--privacy` | `code` `knowledge` `private-local` `automation` | `code` |
| `--purpose` | 写入 README/AGENTS/docs | 待补充 |
| `--notion-url` | Notion Hub URL（`notion-sync`） | 待填写 |
| `--notion-title` | Notion Hub 标题（`notion-sync`） | 项目名 |
| `--github` | `none` `private` `public` | `none` |
| `--push` | 创建远程后 push | 否 |
| `--yes` | 跳过确认 | 否 |
| `--no-commit` | 不自动本地 commit | 否 |
| `--dry-run` | 只展示动作 | 否 |

### 行为

1. 在活动目录创建项目
2. 复制 `templates/ai-project/` 或 `templates/notion-project/`（`--type notion-sync`）
3. 替换占位符
4. `wire_agent_library`：写入 `docs/agent-library.md`、`docs/suggested-assets.md`（`private-local` 跳过）
5. `git init` + 可选 commit
6. 可选 GitHub 创建（需 `gh` 且已登录）
6. 追加 `projects-index.md`

### 限制

- `private-local` 禁止 `--github` 和 `--push`
- `notion-sync` 默认 `knowledge` 隐私策略，强制 `--github none`

### Notion 维护项目示例

```bash
NOTION_HUB_URL="https://www.notion.so/..." \
NOTION_HUB_TITLE="行前准备 Hub" \
./scripts/new-ai-project.sh 260614-trip-prep \
  --type notion-sync --purpose "行前准备双轨维护"
```

---

## upgrade-ai-project.sh

```bash
./scripts/upgrade-ai-project.sh /path/to/project [options]
```

### 参数

| 参数 | 说明 |
|---|---|
| `--type` | 项目类型 |
| `--purpose` | 项目目标 |
| `--yes` | 跳过 Git 初始化询问 |
| `--dry-run` | 只展示将创建的文件 |

### 行为

- 只补齐缺失的模板文件
- **不覆盖**已有文件
- 自动识别 `notion-sync` 项目，并使用 `templates/notion-project/` 补齐 `docs/ai-context.md`、`docs/agent-library.md`、`docs/suggested-assets.md`
- 不默认 commit

---

## batch-upgrade.sh

```bash
./scripts/batch-upgrade.sh [--dry-run]
./scripts/batch-upgrade.sh --execute
```

### 行为

- 扫描活动项目目录一级目录
- 找出缺少 `AGENTS.md` / `docs/runbook.md` / `docs/ai-context.md` / agent-library 挂钩的项目
- 跳过隐藏目录、`ide-toolbox`、`05_Agent-Library` 和明显非项目目录
- 默认 dry-run
- `--execute` 时逐个调用 `upgrade-ai-project.sh`

---

## project-health.sh

```bash
./scripts/project-health.sh /path/to/project
```

### 检查项

- 目录存在
- Git 状态与 remote
- 模板文件完整性
- Notion 项目额外检查 `docs/ai-context.md`、agent-library 挂钩、Last Session 移交状态
- 敏感文件模式
- `gh` 就绪情况
- 最近修改时间

### 输出

- `[OK]` / `[WARN]` 列表
- 总结与建议

---

## agent-cli.sh

```bash
./scripts/agent-cli.sh start /path/to/project [--dry-run]
./scripts/agent-cli.sh plan /path/to/project "任务目标" [--dry-run]
./scripts/agent-cli.sh run /path/to/project "任务目标" [--execute]
./scripts/agent-cli.sh milestone /path/to/project [--dry-run]
./scripts/agent-cli.sh new-notion PROJECT_NAME --purpose "项目目标" [--dry-run]
```

### 行为

- 调用 `query-agent-assets.sh` 生成 Suggested Assets 上下文
- 用 `templates/agent-cli/*.md` 和 `agent-cli-prompt.py` 组装标准 prompt
- 默认使用 `cursor agent --print --workspace <project>`
- `start` / `plan` 默认只读；`run` 未加 `--execute` 时强制计划模式
- `run --execute` 后按配置运行 `project-health.sh` 和 `session-handoff.sh --dry-run`
- 不默认使用 `--force` / `--yolo`

### 风险

- `--dry-run` 只生成 prompt，不调用 Agent
- `run --execute` 可能修改项目文件；若 Git 工作区不干净且配置要求干净工作区，会拒绝执行
- 删除、覆盖、权限、密钥、Git push、Notion 大规模结构修改仍必须等待用户确认

---

## check-device.sh

```bash
./scripts/check-device.sh
```

### 检查项

- 设备名、设备 profile、系统
- `git` / `gh`
- 活动目录、归档目录、工具箱、ide 入口（按 `devices.<profile>` 推荐路径）
- 当前默认活动项目根目录（`resolve_active_dir`）

只读，不修改任何文件。

---

## register-device.sh

```bash
./scripts/register-device.sh /path/to/project [--note "备注"] [--dry-run]
```

### 行为

- 创建或更新项目内 `docs/devices.md`
- 记录：设备名、本地路径、时间、备注
- 同设备重复登记则更新时间与路径

---

## capture-conversation.sh

```bash
./scripts/capture-conversation.sh /path/to/project [--title "标题"] [--dry-run]
```

### 行为

在 `docs/` 下生成 `YYYYMMDD-HHMMSS-标题.md` 对话沉淀模板。

---

## archive-project.sh

```bash
./scripts/archive-project.sh /path/to/project
./scripts/archive-project.sh /path/to/project --execute
```

### 行为

- 默认 dry-run，显示目标归档路径
- `--execute` 时移动到 `01_Project Files/99_归档/`
- 移动前需确认

---

## init-agent-library.sh

```bash
./scripts/init-agent-library.sh [--dry-run] [--yes]
```

创建 `05_Agent-Library` 骨架（README、manifest、子目录、git init）。目录已存在时仅补齐缺失项。

## query-agent-assets.sh

```bash
./scripts/query-agent-assets.sh --task "申根 材料" --type knowledge --privacy knowledge
./scripts/query-agent-assets.sh --purpose "验证挂钩" --output docs/suggested-assets.md
```

按 manifest `entries` 匹配 triggers/tags/project_types；`private-local` 返回空。

## promote-agent-asset.sh

```bash
./scripts/promote-agent-asset.sh \
  --project /path/to/project \
  --source docs/my-playbook.md \
  --id my-playbook --title "标题" \
  --tags "ide,toolbox" --triggers "ide-toolbox,多端"
```

复制文件到 05 库、追加 manifest、在库内 `git commit`（默认需确认）。

---

## lib.sh 公共函数

| 函数 | 用途 |
|---|---|
| `read_policy_value` | 读取 YAML 配置 |
| `read_device_policy_value` | 读取设备段配置 |
| `detect_device_profile` | 识别 macbook/windows/macmini |
| `resolve_active_dir` | 解析活动项目根目录 |
| `resolve_agent_library_dir` | 解析 05_Agent-Library 路径 |
| `wire_agent_library` | 新建项目后写入 suggested-assets |
| `privacy_profile_allows_agent_library` | 是否允许读共享库 |
| `project_missing_agent_library_hook` | 是否缺 agent-library.md |
| `list_recent_projects` | 最近项目列表 |
| `privacy_profile_allows_github` | 隐私策略是否允许 GitHub |
| `project_missing_scaffold` | 判断是否缺模板 |
| `normalize_dragged_path` | 清理拖入路径 |
| `check_sensitive_files` | 敏感文件检测 |

---

## 建议 commit message

| 场景 | 消息 |
|---|---|
| 新建项目 | `chore: initialize AI project scaffold` |
| 升级项目 | `docs: add AI agent workflow scaffold` |
| 对话沉淀 | `docs: capture reusable conversation logic` |
| 工具箱本身 | `feat: enhance ide toolbox ...` |
