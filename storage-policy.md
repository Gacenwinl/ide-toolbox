# NAS / Drive 存储策略

## 总体原则

- NAS 负责文件存放、同步、备份
- GitHub private repo 负责代码和 Agent 上下文主线
- Cursor/Codex 负责执行
- `ide-toolbox`（IDE Toolbox）负责项目创建与治理

## 共享文件夹语义

| 位置 | 用途 | 是否放项目 |
|---|---|---|
| `Download` | 临时下载中转 | 否 |
| `home/Photos`、`photo` | 照片库 | 否 |
| `media`、`video` | 影音内容 | 否 |
| `home/Backup` | 设备/Drive 备份 | 否 |
| `home/Drive/00_FileStation` | 活动项目工作台 | 是 |
| `home/Drive/01_Project Files` | 项目库/归档区 | 是（冷项目） |
| `home/Drive/02_Resources Files` | 资源库 | 否（资料） |
| `home/Drive/03_Study Files` | 学习资料 | 否（学习） |
| `home/Drive/00_FileStation/ide-toolbox` | 项目自动化工具箱（IDE Toolbox） | 否（管理） |

## 项目生命周期

1. 在 `ide-toolbox`（IDE Toolbox）运行 `./ide` 或 `scripts/new-ai-project.sh`
2. 项目创建到 `00_FileStation/YYMMDD-slug`
3. 自动注入 Cursor/Codex 模板
4. 视需要初始化 Git / GitHub private repo
5. 项目不活跃后归档到 `01_Project Files/99_归档`

## 命名建议

- 推荐：`YYMMDD-slug`
- 示例：`260614-cursor-codex-workflow`
- 代码项目优先英文 slug，跨 Windows/macOS/GitHub 更稳

## 不建议做的事

- 不要把 Cursor/Codex 内部聊天数据库当项目记忆
- 不要频繁在活动区和归档区来回搬项目
- 不要把密钥、证件、cookie、token 放进 Git
- 不要把 Synology Drive 当成 Git 替代品

## 多端路径

- NAS 活动目录：`/Volumes/home/Drive/00_FileStation`
- Cursor 同步视图：`/Users/dawncity/Library/CloudStorage/SynologyDrive-FileStation`
- 归档目录：`/Volumes/home/Drive/01_Project Files`
- Windows：在 `config/project-policy.yaml` 的 `devices.windows` 填写 Git Bash 使用的映射盘路径

## 设备概念

- **设备接入检查**：当前这台设备的环境自检（git、gh、路径、工具箱）
- **项目设备登记**：项目内 `docs/devices.md` 记录哪些设备在使用该项目

这不是 Git 被哪些设备 pull 过的列表。

## 相关文档

- [docs/README.md](docs/README.md)
- [docs/architecture.md](docs/architecture.md)
- [docs/onboarding.md](docs/onboarding.md)

## 旧项目策略

- 从今天开始，新项目按本策略创建
- 旧项目只在再次激活时用 `upgrade-ai-project.sh` 升级
- 不建议现在大规模搬迁旧目录
