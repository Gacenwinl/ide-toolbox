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
- 跟进：[docs/20260614-ide-toolbox-followup.md](docs/20260614-ide-toolbox-followup.md)
- **关闭 Cursor IDE 后自维护**：[docs/agent-cli-self-maintenance.md](docs/agent-cli-self-maintenance.md)

## 关闭 Cursor IDE 后如何维护本工具箱

不打开 Cursor 图形界面时，在终端：

```bash
cd ide-toolbox
./agent start .              # 只读接手
./agent plan . "任务目标"     # 只读计划
./agent milestone .          # 里程碑收尾（先 health/handoff 预检）
./agent run . "任务" --execute  # 需 config/agent_cli.allow_execute: true
```

详见 [docs/agent-cli-self-maintenance.md](docs/agent-cli-self-maintenance.md)。

## 会话结束（ substantial 工作后必做）

1. 更新 [docs/ai-context.md](docs/ai-context.md) 的 **Current State** 与 **Last Session**
2. 更新 [docs/changelog.md](docs/changelog.md)
3. 多轮改造写 `docs/YYYYMMDD-*-followup.md` 或运行 `./scripts/capture-conversation.sh .`
4. 运行 `./scripts/session-handoff.sh .` 检查是否可移交
5. 用中文说明：改了什么、为什么、如何验证、如何回滚、建议 commit message

**禁止**只把结论留在聊天记录里。

## 默认动作

- 用户要操作工具箱时，优先运行 `./ide`
- 用户拖入项目路径时，优先用 `./ide <路径>` 进入数字菜单
- 新设备接入时，优先参考 [docs/onboarding.md](docs/onboarding.md) 与 [storage-policy.md](storage-policy.md)
- MacBook / Windows 用 Synology Drive 同步 `00`；Mac mini 用 NAS 挂载
- 长跑 Agent 前优先运行项目体检
- 隐私敏感项目使用 `private-local` 策略
- 用户要升级已有目录时，优先调用 `scripts/upgrade-ai-project.sh`
- 用户要沉淀对话逻辑时，优先调用 `scripts/capture-conversation.sh`
- 用户要收尾移交时，优先调用 `scripts/session-handoff.sh`
- 用户要归档项目时，优先调用 `scripts/archive-project.sh`，真正移动需 `--execute`
- 用户要查共享 Agent 资产时，优先调用 `scripts/query-agent-assets.sh` 或 `./ide` → 查询 Agent 资产库
- 用户要把产出晋升到共享库时，优先调用 `scripts/promote-agent-asset.sh` 或 `./ide` → 晋升资产到库
- 用户要刷新项目建议资产时，优先调用 `query-agent-assets.sh --output docs/suggested-assets.md` 或项目菜单「刷新 suggested-assets」
- 用户要不打开 Cursor IDE、在终端维护项目时，优先调用 `./agent` 或 `scripts/agent-cli.sh`（见 [docs/agent-cli-self-maintenance.md](docs/agent-cli-self-maintenance.md)）
- 维护 **ide-toolbox 自身**时，工作目录就是工具箱根目录，路径用 `.`

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
- `查一下资产库有没有适合这个项目的共享技能`
- `把本次产出晋升到 Agent Library`
- `刷新这个项目的 suggested-assets`
- `用 agent-cli 接手这个项目`
- `用 agent-cli 做里程碑收尾`
