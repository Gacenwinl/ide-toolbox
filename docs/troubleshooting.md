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

- Synology Drive 未同步完成（MacBook / Windows）
- NAS 未挂载（Mac mini 或需访问归档时）
- `devices.*.active_projects` 与真实路径不一致

**处理**

1. MacBook：确认 `~/Library/CloudStorage/SynologyDrive-FileStation` 存在
2. Mac mini：确认 `/Volumes/home/Drive/00_FileStation` 已挂载
3. Windows：确认 `C:/Users/13555/SynologyDrive` 存在
4. 对照 [storage-policy.md](../storage-policy.md) 与 `config/project-policy.yaml`
5. 重新运行 `./scripts/check-device.sh`

### MacBook 混用挂载路径与同步路径

**现象**

同一项目在 Cursor 有时开 CloudStorage，有时开 `/Volumes/home/...`，`devices.md` 路径混乱。

**处理**

- MacBook **固定**用 Drive 同步路径（见 `devices.macbook`）
- 仅在同步目录不可用时依赖脚本回退到 NAS 挂载
- 重新「登记当前设备」更新 `docs/devices.md`

### 拖入路径后提示不存在

**原因**

- 路径带引号、空格、换行
- 拖入的是文件不是目录
- MacBook 拖入了 `/Volumes/home/...` 但本机应用同步路径

**处理**

- 直接运行 `./ide`，输入 `1`–`10` + 回车快速打开最近项目
- 或用手动路径：`./ide ~/Library/CloudStorage/SynologyDrive-FileStation/项目名`（MacBook）

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
- 其他项目 **7 天内无目录活动**（`recent_projects.max_age_days`）

**处理**

- 检查 `resolve_active_dir` 返回值
- 确认 `00_FileStation` 下有其他项目目录
- 需要放宽筛选时，编辑 `config/project-policy.yaml` → `recent_projects.max_age_days`

### 输入编号无对应项目（如选 6 但只有 3 个）

**说明**

快速打开固定占用 **1–10**，最近项目最多显示 **5** 个。空槽位会提示，不会退出程序。

### 无效选项（空）

**原因**

- 旧版菜单 stdout 污染（已修复：UI 走 stderr）
- 非 TTY 环境未设置 `IDE_MENU_PLAIN=1`

**处理**

```bash
IDE_MENU_PLAIN=1 ./ide
```

### 方向键在 Cursor 终端不灵

**处理**

```bash
IDE_MENU_PLAIN=1 ./ide
```

或在本机 Terminal / iTerm 中运行 `./ide`。多数字编号（如 `11`）需 **数字 + 回车**。

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
