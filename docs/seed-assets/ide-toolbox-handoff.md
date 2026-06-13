# ide-toolbox 多端接手 Playbook

## 何时使用

- 新建或接手由 `ide-toolbox` 脚手架创建的项目
- 在 MacBook / Windows / Mac mini 之间切换开发

## 会话启动顺序

1. 读项目 `AGENTS.md`
2. 读 `docs/ai-context.md`、`docs/runbook.md`
3. 读 `docs/agent-library.md` 与 `docs/suggested-assets.md`（非 private-local）
4. 检查 `git status`

## 多端路径

| 设备 | 活动项目根 |
|---|---|
| MacBook | `~/Library/CloudStorage/SynologyDrive-FileStation` |
| Windows | `C:/Users/13555/SynologyDrive` |
| Mac mini | `/Volumes/home/Drive/00_FileStation` |

工具箱：`ide-toolbox`（各端路径见 `docs/devices.md`）

## 常用入口

```bash
./ide
./scripts/project-health.sh .
./scripts/check-device.sh
```

## 禁止

- 未确认不得删除、归档、push
- `private-local` 禁止 GitHub
