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
| 16 | 登记当前设备到项目 |
| 17 | 扫描并升级旧项目 (dry-run) |
| 18 | 设备接入检查 |
| 19 | 检查 GitHub 就绪情况 |
| 20 | 归档预览 |
| 21 | 归档执行 |
| 22 | 查看项目索引 |
| 23 | 查看存储策略 |
| 24 | 更换目标路径 |
| 25 | Codex 接入与用户规则 |
| 26 | 退出 |

### 项目菜单（已选路径后）

| 编号 | 动作 |
|---|---|
| 1 | 项目体检 |
| 2 | 升级 |
| 3 | 沉淀对话记忆 |
| 4 | 登记当前设备 |
| 5 | Git 状态 |
| 6 | GitHub 检查 |
| 7 | 归档预览 |
| 8 | 归档执行 |
| 9 | 更换路径 |
| 10 | 返回主菜单 |
| 11 | 退出 |

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
4. `git init` + 可选 commit
5. 可选 GitHub 创建（需 `gh` 且已登录）
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
- 不默认 commit

---

## batch-upgrade.sh

```bash
./scripts/batch-upgrade.sh [--dry-run]
./scripts/batch-upgrade.sh --execute
```

### 行为

- 扫描 `00_FileStation` 一级目录
- 找出缺少 `AGENTS.md` 或 `docs/runbook.md` 的项目
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
- 敏感文件模式
- `gh` 就绪情况
- 最近修改时间

### 输出

- `[OK]` / `[WARN]` 列表
- 总结与建议

---

## check-device.sh

```bash
./scripts/check-device.sh
```

### 检查项

- 设备名、设备 profile、系统
- `git` / `gh`
- 活动目录、归档目录、工具箱、ide 入口
- Windows 路径是否已填写
- 当前默认活动项目根目录

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

## lib.sh 公共函数

| 函数 | 用途 |
|---|---|
| `read_policy_value` | 读取 YAML 配置 |
| `read_device_policy_value` | 读取设备段配置 |
| `detect_device_profile` | 识别 macbook/windows/macmini |
| `resolve_active_dir` | 解析活动项目根目录 |
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
