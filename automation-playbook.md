# 自动化手册

完整脚本文档见 [docs/scripts-reference.md](docs/scripts-reference.md)。

## 单一入口

```bash
./ide
./ide /path/to/project
```

主菜单能力：

1. 从最近项目选择
2. 新建多端 AI 项目（含隐私策略）
3. 新建 Notion 维护项目（本地 + Notion 双轨）
4. 项目体检
4. 升级已有目录
5. 沉淀对话记忆
6. 登记当前设备到项目
7. 扫描并升级旧项目（dry-run）
8. 设备接入检查
9. GitHub 就绪检查
10. 归档预览 / 执行
11. 查看项目索引 / 存储策略

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
