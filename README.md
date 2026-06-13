# IDE Toolbox — 项目自动化工具箱

Cursor/Codex 多端项目的统一启动与治理目录。日常入口：`./ide`。

## 快速开始

```bash
cd "/Users/dawncity/Library/CloudStorage/SynologyDrive-FileStation/ide-toolbox"
./ide
```

拖入项目路径：

```bash
./ide /Volumes/home/Drive/00_FileStation/260000-Job-Codex
```

新设备第一次使用：先看 [docs/onboarding.md](docs/onboarding.md)

## 文档导航

| 文档 | 用途 |
|---|---|
| [docs/README.md](docs/README.md) | 文档总索引 |
| [docs/onboarding.md](docs/onboarding.md) | 新设备接入 |
| [automation-playbook.md](automation-playbook.md) | 日常操作 |
| [storage-policy.md](storage-policy.md) | 存储策略 |
| [docs/architecture.md](docs/architecture.md) | 系统架构 |
| [docs/scripts-reference.md](docs/scripts-reference.md) | 脚本参考 |
| [docs/troubleshooting.md](docs/troubleshooting.md) | 故障排查 |
| [docs/maintenance.md](docs/maintenance.md) | 维护手册 |
| [docs/changelog.md](docs/changelog.md) | 变更记录 |

## 核心能力

- `./ide` 单一入口 + 最近项目列表
- 新建 / 升级 / 体检 / 归档 / 对话沉淀
- 隐私分级：`private-local` 禁止 GitHub
- 设备接入检查 + 项目设备登记
- Windows 使用 Git Bash（路径见 `config/project-policy.yaml`）

## 验证

```bash
bash -n scripts/*.sh
./scripts/check-device.sh
./scripts/batch-upgrade.sh --dry-run
```

## 回滚

删除工具箱内新增文件即可；不影响 `00_FileStation` 业务项目。详见 [docs/maintenance.md](docs/maintenance.md)。
