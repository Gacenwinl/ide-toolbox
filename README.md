# IDE Toolbox — 项目自动化工具箱

> 可视化总览：用浏览器打开 [README.html](README.html)

Cursor/Codex 多端项目的统一启动与治理目录。日常入口：`./ide`。

## 快速开始

```bash
cd "/Users/dawncity/Library/CloudStorage/SynologyDrive-FileStation/ide-toolbox"
./ide
```

拖入项目路径（MacBook 示例，路径因设备而异）：

```bash
./ide ~/Library/CloudStorage/SynologyDrive-FileStation/260000-Job-Codex
```

路径策略：**MacBook / Windows = Synology Drive 同步 · Mac mini = NAS 挂载**。详见 [storage-policy.md](storage-policy.md)。

新设备第一次使用：先看 [docs/onboarding.md](docs/onboarding.md)

## 文档导航

| 文档 | 用途 |
|---|---|
| [docs/README.md](docs/README.md) | 文档总索引 |
| [docs/onboarding.md](docs/onboarding.md) | 新设备接入 |
| [docs/codex-onboarding.md](docs/codex-onboarding.md) | Codex 用户规则与接入 |
| [automation-playbook.md](automation-playbook.md) | 日常操作 |
| [storage-policy.md](storage-policy.md) | 存储策略（含群晖/Mac/Windows 路径对照） |
| [docs/architecture.md](docs/architecture.md) | 系统架构 |
| [docs/scripts-reference.md](docs/scripts-reference.md) | 脚本参考 |
| [docs/troubleshooting.md](docs/troubleshooting.md) | 故障排查 |
| [docs/maintenance.md](docs/maintenance.md) | 维护手册 |
| [docs/changelog.md](docs/changelog.md) | 变更记录 |

## 核心能力

- `./ide` 单一入口：**1–10** 快速打开最近项目（≤5、7 天内）· **11+** 功能操作
- 新建 / 升级 / 体检 / 归档 / 对话沉淀
- 隐私分级：`private-local` 禁止 GitHub
- 设备接入检查 + 项目设备登记
- Codex 用户级规则模板（对齐 Cursor 项目级 rules）
- **Agent 复利**：`05_Agent-Library` + 新建项目自动 `suggested-assets.md`（见下节）
- 多端路径：**MacBook / Windows** Drive 同步 · **Mac mini** NAS 挂载（见 `storage-policy.md`）

## Agent 复利（Hub）

跨项目 Skill/playbook 不进聊天，而走：

1. **L1** 项目内 `docs/ai-context.md`（Current State / Last Session）
2. **L2** `02_Resources Files/05_Agent-Library` + `manifest.yaml`
3. **工厂**：`./ide` → 11) 新建项目 → 自动 `docs/suggested-assets.md`

```bash
./scripts/query-agent-assets.sh --task "任务关键词"
./scripts/promote-agent-asset.sh --project /path --source docs/x.md --id slug --title "标题"
./scripts/session-handoff.sh /path/to/project   # 会话结束检查
```

详见 [storage-policy.md](storage-policy.md) §05、[docs/ai-context.md](docs/ai-context.md)。

## 验证

```bash
bash -n scripts/*.sh
./scripts/check-device.sh
./scripts/batch-upgrade.sh --dry-run
```

## 回滚

删除工具箱内新增文件即可；不影响 `00_FileStation` 业务项目。详见 [docs/maintenance.md](docs/maintenance.md)。
