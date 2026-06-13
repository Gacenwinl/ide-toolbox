# 变更记录

ide-toolbox 工具箱自身变更，不是业务项目 changelog。

## 2026-06-13 — Notion 项目模板 + Git 初始化

### 新增

- `templates/notion-project/` 本地 + Notion 双轨维护模板
- `./ide` 主菜单「新建 Notion 维护项目」
- `new-ai-project.sh` 支持 `--type notion-sync`
- `project-health.sh` 识别 Notion 项目并检查 manifest / NOTION_INDEX

### 更新

- `config/project-policy.yaml` 增加 `notion-sync` 类型
- `docs/scripts-reference.md`、`automation-playbook.md`

## 2026-06-13 — 项目重命名

- 目录名由 `IDE Management` 重命名为 `ide-toolbox`
- 显示名统一为 **IDE Toolbox**
- 入口命令保持 `./ide`

## 2026-06-13 — 文档体系补全

### 新增

- `docs/README.md` 文档索引
- `docs/architecture.md` 系统架构
- `docs/onboarding.md` 新设备接入
- `docs/scripts-reference.md` 脚本参考
- `docs/troubleshooting.md` 故障排查
- `docs/maintenance.md` 维护手册
- `docs/changelog.md` 本文件

### 更新

- `README.md` 指向 docs 目录
- `AGENTS.md` 增加文档阅读顺序
- `storage-policy.md` 统一入口为 `./ide`
- `automation-playbook.md` 链接脚本文档

## 2026-06-13 — 工具箱体验优化

### 新增

- `scripts/ide.sh` / `ide` 单一交互入口
- `scripts/project-health.sh` 项目体检
- `scripts/batch-upgrade.sh` 批量升级（默认 dry-run）
- `scripts/check-device.sh` 设备接入检查
- `scripts/register-device.sh` 项目设备登记
- `templates/ai-project/docs/devices.md` 设备台账模板

### 更新

- `scripts/lib.sh`：最近项目、设备 profile、隐私策略
- `scripts/ide.sh`：两级数字菜单
- `config/project-policy.yaml`：`devices`、`privacy_profiles`
- `scripts/new-ai-project.sh`：`--privacy`、`private-local` 禁止 GitHub

## 2026-06-13 — 项目自动化工具箱初版

### 新增

- `scripts/new-ai-project.sh`
- `scripts/upgrade-ai-project.sh`
- `scripts/capture-conversation.sh`
- `scripts/archive-project.sh`
- `templates/ai-project/` 标准模板
- `config/project-policy.yaml`
- `README.md`、`AGENTS.md`、`storage-policy.md`、`automation-playbook.md`

### 策略

- 活动项目在 `00_FileStation`
- 归档项目在 `01_Project Files`
- GitHub 可选，默认不 push
- 不自动安装依赖
