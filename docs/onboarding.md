# 新设备接入指南

目标：在新设备上 5 分钟内确认工具箱可用，并能新建或接手一个项目。

## 前置条件

- 已安装 Git
- 已能访问 NAS / Synology Drive 同步目录
- Mac / Mac mini：终端 bash 即可
- Windows：使用 **Git Bash**（你已选择此方案）

## Mac / Mac mini

### 1. 进入工具箱

```bash
cd "/Users/dawncity/Library/CloudStorage/SynologyDrive-FileStation/ide-toolbox"
# 或 NAS 挂载路径：
# cd "/Volumes/home/Drive/00_FileStation/ide-toolbox"
```

### 2. 设备接入检查

```bash
./scripts/check-device.sh
```

期望看到：

- `[OK] git 已安装`
- `[OK] 活动目录 可达`
- `[OK] 工具箱目录 可达`
- `[OK] ide 入口 可达`

`gh` 未安装只会 WARN，不阻塞本地使用。

### 3. 试运行入口

```bash
./ide
```

应看到：

- 设备名与设备配置（`macbook` 或 `macmini`）
- 最近活动项目列表
- 主菜单数字选项

### 4. 接手已有项目

```bash
./ide /Volumes/home/Drive/00_FileStation/你的项目名
```

推荐顺序：

1. 项目体检
2. 登记当前设备
3. 开始 Cursor/Codex 工作

### 5. 可选：启用 GitHub 自动化

```bash
# 安装 gh 后（需你确认安装）
gh auth login
./ide
# 主菜单 → 检查 GitHub 就绪情况
```

## Windows（Git Bash）

### 1. 填写设备路径

编辑 `config/project-policy.yaml`：

```yaml
devices:
  windows:
    shell: git-bash
    active_projects: "你的映射盘路径/00_FileStation"
    toolbox: "你的映射盘路径/00_FileStation/ide-toolbox"
```

示例（按你实际盘符修改）：

```yaml
active_projects: "Z:/Drive/00_FileStation"
toolbox: "Z:/Drive/00_FileStation/ide-toolbox"
```

### 2. 打开 Git Bash 并进入工具箱

```bash
cd "/z/Drive/00_FileStation/ide-toolbox"
./ide
```

### 3. 设备接入检查

```bash
./scripts/check-device.sh
```

若活动目录不可达，回到 `project-policy.yaml` 修正 Windows 路径。

### 4. 登记设备

在某个项目里：

```bash
./scripts/register-device.sh "/你的路径/项目名" --note "Windows 主编辑机"
```

## 新项目首次验证

```bash
./ide
# 2) 新建多端 AI 项目
```

或：

```bash
./scripts/new-ai-project.sh 260614-test-onboarding --purpose "接入验证" --dry-run
./scripts/new-ai-project.sh 260614-test-onboarding --purpose "接入验证"
./scripts/project-health.sh "/Volumes/home/Drive/00_FileStation/260614-test-onboarding"
```

验证通过后，可在 Cursor 中打开新项目目录。

## 隐私项目接入

求职、签证、证件类项目：

```bash
./scripts/new-ai-project.sh 260614-visa --privacy private-local --purpose "签证资料"
```

`private-local` 会自动禁止 GitHub 创建。

## 接入完成检查清单

- [ ] `./scripts/check-device.sh` 无关键 ERROR
- [ ] `./ide` 能显示最近项目
- [ ] 能对一个已有项目做体检
- [ ] 能登记当前设备到 `docs/devices.md`
- [ ] 知道活动目录与归档目录位置
- [ ] （可选）`gh auth login` 完成

## 下一步

- 日常操作：[automation-playbook.md](../automation-playbook.md)
- 存储规则：[storage-policy.md](../storage-policy.md)
- 出问题：[troubleshooting.md](troubleshooting.md)
