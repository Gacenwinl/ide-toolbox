# 自动化手册

完整脚本文档见 [docs/scripts-reference.md](docs/scripts-reference.md)。

## 单一入口

```bash
./ide
./ide /path/to/project
```

主菜单为**合一列表**，编号固定：

| 编号 | 能力 |
|---|---|
| **1–10** | 快速打开最近项目（最多 5 个、7 天内有目录活动；空槽位友好提示） |
| **11** | 新建多端 AI 项目（含隐私策略） |
| **12** | 新建 Notion 维护项目（本地 + Notion 双轨） |
| **13** | 项目体检 |
| **14** | 升级已有目录 |
| **15** | 沉淀对话记忆 |
| **16** | 会话收尾移交检查 |
| **17** | 登记当前设备到项目 |
| **18** | 扫描并升级旧项目（dry-run） |
| **19** | 设备接入检查 |
| **20** | GitHub 就绪检查 |
| **21** | 归档预览 |
| **22** | 归档执行 |
| **23** | 查看项目索引 |
| **24** | 查看存储策略 |
| **25** | 查询 Agent 资产库 |
| **26** | 晋升资产到库 |
| **27** | 初始化 Agent Library |
| **28** | 更换目标路径 |
| **29** | Agent CLI 自动驾驶（`scripts/agent-cli.sh` 或 `./agent`） |
| **30** | Codex 接入与用户规则（`docs/codex-onboarding.md`） |
| **31** | 退出 |

### 项目菜单（已选路径后）

| 编号 | 能力 |
|---|---|
| **1** | 项目体检 |
| **2** | 升级 |
| **3** | 沉淀对话记忆 |
| **4** | 会话收尾移交检查 |
| **5** | 登记当前设备 |
| **6** | 刷新 suggested-assets |
| **7** | 晋升本项目资产到库 |
| **8** | Git 状态 |
| **9** | GitHub 检查 |
| **10** | Agent CLI 自动驾驶 |
| **11** | 归档预览 |
| **12** | 归档执行 |
| **13** | 更换路径 |
| **14** | 返回主菜单 |
| **15** | 退出 |

**操作：** ↑↓ / jk 移动 · 回车确认 · **数字 + 回车**跳转（如 `11`+回车）· `0` 退出。  
Cursor 终端方向键不稳时：`IDE_MENU_PLAIN=1 ./ide`

最近项目筛选见 `config/project-policy.yaml` → `recent_projects`（`limit: 5`、`max_age_days: 7`）。

## 隐私策略

| 策略 | GitHub |
|---|---|
| `code` | 可选 private |
| `knowledge` | 默认 none |
| `private-local` | 禁止 |
| `automation` | 可选 private |

```bash
./scripts/new-ai-project.sh 260614-visa --privacy private-local --purpose "签证资料"
```

## 设备相关

### 设备接入检查

检查当前设备环境，不是 Git pull 设备列表：

```bash
./scripts/check-device.sh
```

### 项目设备登记

```bash
./scripts/register-device.sh /path/to/project --note "主开发机"
```

## Windows Git Bash

详见 [docs/onboarding.md](docs/onboarding.md#windowsgit-bash)。

## 多端路径（推荐）

| 设备 | 方式 | 工具箱路径 |
|---|---|---|
| MacBook | Drive 同步 | `~/Library/CloudStorage/SynologyDrive-FileStation/ide-toolbox` |
| Windows | Drive 同步 | `C:/Users/13555/SynologyDrive/ide-toolbox` |
| Mac mini | NAS 挂载 | `/Volumes/home/Drive/00_FileStation/ide-toolbox` |

详见 [storage-policy.md](storage-policy.md)。

## 新项目生命周期（复利）

```text
./ide → 11) 新建项目
  → new-ai-project.sh 复制模板 + wire_agent_library
  → 项目内自动生成 docs/suggested-assets.md
Cursor 打开项目 → AGENTS.md 指引读 suggested-assets
任务结束 → capture-conversation.sh（含晋升评估）
第二次跨项目仍需要 → promote-agent-asset.sh 或 ./ide → 26)
```

## Agent CLI 自动驾驶（可不打开 Cursor IDE）

关闭 Cursor 图形界面后，在终端维护工具箱或业务项目：

```bash
cd ide-toolbox
./agent chat .                              # 多轮交互（最接近 IDE）
./agent continue . "补充需求"
./agent start . --dry-run
./agent start .
./agent plan . "任务目标"
./agent milestone . --summary "本段完成了什么"
./agent run . "任务目标" --execute   # 需 config/agent_cli.allow_execute: true
```

维护 ide-toolbox 自身详见 [docs/agent-cli-self-maintenance.md](docs/agent-cli-self-maintenance.md)。Plan / Subagent 见 [docs/agent-cli-modes-and-subagents.md](docs/agent-cli-modes-and-subagents.md)。

## 直接脚本

```bash
./scripts/project-health.sh /path/to/project
./scripts/batch-upgrade.sh --dry-run
./scripts/batch-upgrade.sh --execute
./agent start . --dry-run
./agent milestone .
```

## 出问题

见 [docs/troubleshooting.md](docs/troubleshooting.md)。

## AI 口令

- `新建一个多端 AI 项目，名字叫 xxx，用途是 xxx`
- `把这个目录升级成 Cursor/Codex 多端项目`
- `把当前对话沉淀成项目记忆`
- `按长跑模式执行这个项目`
- `检查这个项目是否适合放 GitHub private repo`
- `把这个项目归档`
- `查一下资产库有没有适合这个项目的共享技能`
- `把本次产出晋升到 Agent Library`
- `刷新这个项目的 suggested-assets`
- `按 session-handoff 检查这个项目能否移交`
- `用 agent-cli 接手这个项目，不要改文件`
- `用 agent-cli 给这个任务做计划`
- `用 agent-cli 做里程碑收尾`

我会优先调用这里定义的脚本，而不是让你手动建目录。
