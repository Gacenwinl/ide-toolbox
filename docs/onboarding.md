# 新设备接入指南

目标：在新设备上 5 分钟内确认工具箱可用，并能新建或接手一个项目。

## 前置条件

- 已安装 Git
- 已能访问 Synology Drive 同步目录或 NAS 挂载
- MacBook / Windows：Synology Drive 客户端已同步 `00_FileStation`
- Mac mini：NAS 已挂载到 `/Volumes/home`
- Windows：使用 **Git Bash**

## 推荐路径策略

| 设备 | 进入工具箱 | 配置键 |
|---|---|---|
| MacBook | `~/Library/CloudStorage/SynologyDrive-FileStation/ide-toolbox` | `devices.macbook` |
| Mac mini | `/Volumes/home/Drive/00_FileStation/ide-toolbox` | `devices.macmini` |
| Windows | `C:/Users/13555/SynologyDrive/ide-toolbox` | `devices.windows` |

详见 [storage-policy.md](../storage-policy.md)。

## MacBook（Synology Drive 同步）

与 Windows 统一，优先用 Drive 同步目录，外出/离线也可工作。

### 1. 进入工具箱

```bash
cd "/Users/dawncity/Library/CloudStorage/SynologyDrive-FileStation/ide-toolbox"
```

### 2. 设备接入检查

```bash
./scripts/check-device.sh
```

期望：`[OK] 活动目录 可达` 指向 CloudStorage 路径。

### 3. 试运行

```bash
./ide
```

### 4. 接手已有项目

```bash
./ide ~/Library/CloudStorage/SynologyDrive-FileStation/你的项目名
```

推荐：项目体检 → 登记当前设备 → 在 Cursor 用**同一路径**打开项目目录。

## Mac mini（NAS 挂载）

家里固定机，走 SMB 挂载，适合长跑脚本与归档操作。

### 1. 进入工具箱

```bash
cd "/Volumes/home/Drive/00_FileStation/ide-toolbox"
```

### 2. 设备接入检查

```bash
./scripts/check-device.sh
```

期望：`[OK] 活动目录 可达` 指向 `/Volumes/home/Drive/00_FileStation`。

### 3. 试运行

```bash
./ide
```

### 4. 接手已有项目

```bash
./ide /Volumes/home/Drive/00_FileStation/你的项目名
```

归档预览/执行建议在 Mac mini 上进行（`01_Project Files` 挂载可达）。

## Windows（Git Bash）

### 1. 确认设备路径

```yaml
devices:
  windows:
    active_projects: "C:/Users/13555/SynologyDrive"
    toolbox: "C:/Users/13555/SynologyDrive/ide-toolbox"
```

### 2. 进入工具箱

```bash
cd "C:/Users/13555/SynologyDrive/ide-toolbox"
./ide
```

### 3. 设备接入检查

```bash
./scripts/check-device.sh
```

### 4. 登记设备

```bash
./scripts/register-device.sh "C:/Users/13555/SynologyDrive/你的项目名" --note "Windows 主编辑机"
```

## 所有设备：菜单与操作

`./ide` 主菜单：

- **1–10** 快速打开最近项目（≤5、7 天内）
- **11+** 新建 / 体检 / 归档等
- **↑↓ / jk**、**数字 + 回车**（如 `11`+回车）

Cursor 终端方向键不稳：`IDE_MENU_PLAIN=1 ./ide`

### 可选：GitHub

```bash
gh auth login   # 需你确认安装 gh
./ide
# 19) 检查 GitHub 就绪情况
```

## 新项目首次验证

```bash
./ide
# 11) 新建多端 AI 项目
```

或：

```bash
./scripts/new-ai-project.sh 260614-test-onboarding --purpose "接入验证" --dry-run
./scripts/new-ai-project.sh 260614-test-onboarding --purpose "接入验证"
```

MacBook 示例：

```bash
./scripts/project-health.sh "$HOME/Library/CloudStorage/SynologyDrive-FileStation/260614-test-onboarding"
```

Mac mini 示例：

```bash
./scripts/project-health.sh "/Volumes/home/Drive/00_FileStation/260614-test-onboarding"
```

## 隐私项目接入

```bash
./scripts/new-ai-project.sh 260614-visa --privacy private-local --purpose "签证资料"
```

## Codex 一次性配置

[docs/codex-onboarding.md](codex-onboarding.md) + [docs/codex-user-rule-template.md](codex-user-rule-template.md) → Codex **User Rules**（每台设备一次）。

`./ide` → **25) Codex 接入与用户规则**

## Obsidian（可选）

Obsidian 只能作为**同一批 Markdown 的阅读界面**，不要另建一套 Agent 记忆。

推荐：

- Vault 直接打开 `~/Library/CloudStorage/SynologyDrive-FileStation` 或其中的项目目录
- 项目状态仍写 `docs/ai-context.md`，跨项目资产仍写 `02_Resources Files/05_Agent-Library/manifest.yaml`
- Obsidian 只负责双链、浏览、人工整理；Agent 接手仍以 `AGENTS.md` 和 `docs/ai-context.md` 为真相源

不推荐：

- 另建 “Agent Memory Vault” 并复制项目结论
- 把 `private-local` 项目放入公共 vault
- 用 Obsidian 链接替代 `session-handoff.sh` 或 `query-agent-assets.sh`

## 接入完成检查清单

- [ ] `./scripts/check-device.sh` 活动目录为**本设备推荐路径**
- [ ] `./ide` 能显示最近项目
- [ ] Cursor 打开路径与 `./ide` 一致（不混用挂载/同步）
- [ ] 已登记当前设备到 `docs/devices.md`
- [ ] （Codex）用户规则已配置
- [ ] substantial 工作结束前知道如何运行 `session-handoff.sh`
- [ ] （可选 Obsidian）确认没有第二套 Agent 记忆
- [ ] （可选）`gh auth login` 完成

## 下一步

- [automation-playbook.md](../automation-playbook.md)
- [storage-policy.md](../storage-policy.md)
- [troubleshooting.md](troubleshooting.md)
