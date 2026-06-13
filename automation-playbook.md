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
| **16** | 登记当前设备到项目 |
| **17** | 扫描并升级旧项目（dry-run） |
| **18** | 设备接入检查 |
| **19** | GitHub 就绪检查 |
| **20** | 归档预览 |
| **21** | 归档执行 |
| **22** | 查看项目索引 |
| **23** | 查看存储策略 |
| **24** | 更换目标路径 |
| **25** | Codex 接入与用户规则（`docs/codex-onboarding.md`） |
| **26** | 退出 |

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

## 直接脚本

```bash
./scripts/project-health.sh /path/to/project
./scripts/batch-upgrade.sh --dry-run
./scripts/batch-upgrade.sh --execute
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

我会优先调用这里定义的脚本，而不是让你手动建目录。
