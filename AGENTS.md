# AGENTS.md — IDE Toolbox

## 角色

本目录是 Cursor/Codex 项目自动化工具箱，不是业务项目目录。

## 会话启动

1. [README.md](README.md)
2. [docs/ai-context.md](docs/ai-context.md)
3. [docs/runbook.md](docs/runbook.md)
4. [docs/README.md](docs/README.md)
5. [storage-policy.md](storage-policy.md)
6. [automation-playbook.md](automation-playbook.md)
7. [config/project-policy.yaml](config/project-policy.yaml)
8. [projects-index.md](projects-index.md)

按需深入：

- 架构：[docs/architecture.md](docs/architecture.md)
- 脚本：[docs/scripts-reference.md](docs/scripts-reference.md)
- 排错：[docs/troubleshooting.md](docs/troubleshooting.md)

## 默认动作

- 用户要操作工具箱时，优先运行 `./ide`
- 用户拖入项目路径时，优先用 `./ide <路径>` 进入数字菜单
- 新设备接入时，优先参考 [docs/onboarding.md](docs/onboarding.md)
- 长跑 Agent 前优先运行项目体检
- 隐私敏感项目使用 `private-local` 策略
- 用户要升级已有目录时，优先调用 `scripts/upgrade-ai-project.sh`
- 用户要沉淀对话逻辑时，优先调用 `scripts/capture-conversation.sh`
- 用户要归档项目时，优先调用 `scripts/archive-project.sh`，真正移动需 `--execute`

## 安全规则

- 先检查 Git 状态
- 不删除、不覆盖、不移动旧项目，除非用户明确确认
- 不自动安装 `gh` 或其他依赖
- GitHub 创建、push、归档移动必须确认或显式参数
- 回答使用中文
- 每次修改后说明：改了什么、为什么改、如何验证、如何回滚
- 修改工具箱后更新 [docs/changelog.md](docs/changelog.md)

## Cursor vs Codex

| 工具 | 项目级自动规则 | 推荐补齐 |
|---|---|---|
| Cursor | `.cursor/rules/*.mdc`（新建项目自带） | 用户级规则可选 |
| Codex | 无 `.codex/rules` | **用户级规则必配一次** → [docs/codex-user-rule-template.md](docs/codex-user-rule-template.md) |

业务项目内 `docs/codex-handoff.md` 供 Codex 每次会话快速接手。

## 自动化口令

- `新建一个多端 AI 项目，名字叫 xxx，用途是 xxx`
- `把这个目录升级成 Cursor/Codex 多端项目`
- `把当前对话沉淀成项目记忆`
- `按长跑模式执行这个项目`
- `检查这个项目是否适合放 GitHub private repo`
- `把这个项目归档`
