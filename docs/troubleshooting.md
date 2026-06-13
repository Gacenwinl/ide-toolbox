# 故障排查

按现象查找。修复前优先运行 `./scripts/check-device.sh`。

## 路径与挂载

### 找不到活动项目目录

**现象**

```text
找不到活动项目目录
找不到 Windows 活动项目目录
```

**原因**

- NAS 未挂载
- Synology Drive 未同步
- Windows 路径未填写

**处理**

1. 确认 `/Volumes/home/Drive/00_FileStation` 或 Cursor 同步目录存在
2. Windows：编辑 `config/project-policy.yaml` 的 `devices.windows`
3. 重新运行 `./scripts/check-device.sh`

### 拖入路径后提示不存在

**原因**

- 路径带引号、空格、换行
- 拖入的是文件不是目录

**处理**

- 直接运行 `./ide`，用菜单 `1` 从最近项目选择
- 或手动输入无引号路径

---

## Git 与 GitHub

### gh 未安装

**现象**

```text
[WARN] gh 未安装
```

**影响**

- 本地新建、升级、体检不受影响
- 无法自动创建 GitHub 仓库

**处理**

- 仅本地使用：可忽略
- 需要远程：安装 `gh` 后执行 `gh auth login`（安装前需你确认）

### private-local 禁止 GitHub

**现象**

```text
隐私策略 private-local 禁止创建 GitHub 仓库
```

**说明**

这是预期行为，不是故障。

### Git 工作区不干净

**现象**

体检报告：`Git 工作区不干净`

**处理**

1. 进入项目目录 `git status`
2. 决定 commit、stash 或继续（长跑 Agent 前先处理）

---

## 项目模板

### 缺少 AGENTS.md / docs/runbook.md

**处理**

```bash
./scripts/upgrade-ai-project.sh "/path/to/project"
# 或批量
./scripts/batch-upgrade.sh --dry-run
./scripts/batch-upgrade.sh --execute
```

### 批量升级后想回滚

升级脚本不覆盖已有文件。回滚 = 删除本次新增的文件：

- `AGENTS.md`
- `docs/ai-context.md`
- `docs/runbook.md`
- `docs/conversation-reuse.md`
- `docs/devices.md`
- `.cursor/rules/ai-agent-workflow.mdc`

---

## 设备与多端

### 设备识别错误

**现象**

Mac 被识别为 `windows`（旧版本可能出现）

**处理**

- 当前版本已按 `Darwin` 优先识别
- 更新 `scripts/lib.sh` 后重试 `./scripts/check-device.sh`

### 设备接入检查 vs 项目设备登记

| 功能 | 作用 |
|---|---|
| `check-device.sh` | 当前设备环境自检 |
| `register-device.sh` | 写入项目 `docs/devices.md` |

两者都不是“Git 被哪些设备 pull 过”的列表。

---

## 归档

### 归档目标已存在

**现象**

```text
归档目标已存在
```

**处理**

- 检查 `01_Project Files/99_归档/` 是否已有同名目录
- 手动改名或清理后再归档

### 误归档

**处理**

- 从 `01_Project Files/99_归档/项目名` 移回 `00_FileStation/项目名`
- 更新 `projects-index.md`

---

## 脚本与菜单

### bash -n 通过但运行报错

**常见原因**

- 用 `zsh` 直接 `source scripts/lib.sh`（应通过 `bash` 运行脚本）
- 在非 bash 环境调用

**处理**

```bash
bash ./ide
bash ./scripts/check-device.sh
```

### 最近项目列表为空

**原因**

- 活动目录为空或不可达
- 只有 `ide-toolbox` 一个目录

**处理**

- 检查 `resolve_active_dir` 返回值
- 确认 `00_FileStation` 下有其他项目目录

---

## 敏感文件

### 体检报告提示疑似敏感文件

**处理**

1. 确认 `.gitignore` 已忽略相关文件
2. 不要将 `.env`、证件、密钥提交到 Git
3. 隐私项目使用 `private-local` 策略

---

## 仍无法解决

1. 运行 `./scripts/check-device.sh` 保存输出
2. 运行 `./scripts/project-health.sh /path/to/project`
3. 查看 [scripts-reference.md](scripts-reference.md) 确认参数
4. 在 Cursor 中把报错贴给 Agent，并说明正在使用 ide-toolbox 工具箱
