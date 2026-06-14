# 关闭 Cursor IDE 后，用 Agent CLI 维护 ide-toolbox

本文说明：**不打开 Cursor 图形界面**，如何在终端里让 `ide-toolbox` 调用 `cursor agent` 维护工具箱自身或其他项目。

## 前置条件

1. 已安装 Cursor CLI：`cursor agent --help` 可用
2. 已进入工具箱目录（MacBook 示例）：

```bash
cd "/Users/dawncity/Library/CloudStorage/SynologyDrive-FileStation/ide-toolbox"
```

3. 建议先 commit 当前改动，否则 `run --execute` 可能因 Git 工作区不干净被拒绝

## 维护 ide-toolbox 自身（推荐流程）

### 1. 只读接手（不改文件）

```bash
./scripts/agent-cli.sh start . --dry-run    # 先看 prompt
./scripts/agent-cli.sh start .            # 真正调用 Agent，只读汇报
```

### 2. 制定计划

```bash
./scripts/agent-cli.sh plan . "检查 agent-cli 实现并给出最小改进计划"
```

### 3. 受控执行

先在 `config/project-policy.yaml` 确认：

```yaml
agent_cli:
  allow_execute: true   # 需要改文件时开启
```

然后：

```bash
./scripts/agent-cli.sh run . "实现 xxx" --execute
```

### 4. 里程碑收尾

```bash
./scripts/agent-cli.sh milestone .
./scripts/agent-cli.sh milestone . --summary "本段完成了什么"
```

会自动先跑 `project-health.sh` 和 `session-handoff.sh --dry-run`，再让 Agent 补充 `docs/ai-context.md`，并**验证文件是否真的被修改**。

### 5. 多轮对话（像 IDE 聊天）

```bash
./scripts/agent-cli.sh chat .                    # 交互 TUI，可连续追问
./scripts/agent-cli.sh continue . "补充需求：…"   # 续上一段 CLI 会话
```

退出交互会话后，记得 `./agent milestone .`。

Plan 模式与子 Agent 说明见 [agent-cli-modes-and-subagents.md](agent-cli-modes-and-subagents.md)。

## 交互菜单（可选）

```bash
./ide .
# 主菜单 29) Agent CLI 自动驾驶
# 或进入项目后选 10) Agent CLI 自动驾驶
```

## 维护其他业务项目

```bash
./scripts/agent-cli.sh start /path/to/260614-gym-monitor
./scripts/agent-cli.sh plan /path/to/project "任务目标"
./scripts/agent-cli.sh milestone /path/to/project
```

## 每次 substantial 工作后必做

1. 更新 `docs/ai-context.md` → Current State / Last Session
2. 更新 `docs/changelog.md`
3. `./scripts/session-handoff.sh .`
4. `git commit`（建议）

## 安全边界

- 默认不用 `--force` / `--yolo`
- `private-local` 项目禁止晋升 Agent Library
- 删除、覆盖、push、权限、密钥操作仍需你确认
- `config/agent_cli.allow_execute` 默认 `false`，防止误执行

## 常见问题

| 问题 | 处理 |
|---|---|
| `manifest 不存在` | 运行 `./scripts/init-agent-library.sh --yes` |
| `执行模式要求干净工作区` | 先 commit 或 stash，或只用 plan/start |
| `allow_execute=false` | 在 `project-policy.yaml` 设为 `true` 后再 `run --execute` |
| Agent 没读项目文件 | 用 `start`/`plan`，不要跳过 `agent-cli.sh` 直接口述 |
| milestone 后 ai-context 未变化 | 用 `--summary` 或 `./agent chat .` 后再 milestone |
| 想多轮追问 | 用 `./agent chat .` 或 `./agent continue .` |

## 相关文档

- [README.md](../README.md) — Agent CLI 自动驾驶总览
- [agent-cli-modes-and-subagents.md](agent-cli-modes-and-subagents.md) — Plan 模式、多轮对话、Subagent
- [docs/scripts-reference.md](scripts-reference.md) — 完整参数
- [docs/runbook.md](runbook.md) — 工具箱维护长跑
- [AGENTS.md](../AGENTS.md) — Agent 接手规则
