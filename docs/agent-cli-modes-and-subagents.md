# Agent CLI：Plan 模式、多轮对话与子 Agent

本文回答三个常见问题：

1. **Plan 模式**能在 tool 里用吗？
2. **多轮追问**（像 Cursor IDE 聊天）怎么做？
3. **Subagent（子 Agent）**能在 tool 里用吗？

---

## Plan 模式 —— 能用，且是默认

| 命令 | 行为 |
|---|---|
| `./agent start .` | 默认 `--mode plan`，只读接手 |
| `./agent plan . "任务"` | 只读计划，不改文件 |
| `./agent run . "任务"` | **无 `--execute` 时强制 plan** |
| `./agent run . "任务" --execute` | 执行模式（需 `allow_execute: true`） |

底层调用：`cursor agent --mode plan --print --workspace ...`

显式问答模式：

```bash
./agent plan . "解释架构" --mode ask
```

---

## 多轮对话 —— 三种方式

### 方式 A：`chat`（最接近 IDE 聊天）

打开 **Cursor 交互 TUI**（不用 `--print`），在同一会话里连续追问：

```bash
./agent chat .
./agent chat . "先接手项目，我会继续追问"
```

退出后若做了 substantial 工作：

```bash
./agent milestone .
```

### 方式 B：`continue`（续上一段 CLI 会话）

```bash
./agent continue .
./agent continue . "补充需求：增加邮件提醒"
```

底层：`cursor agent --continue --workspace ...`

### 方式 C：单轮 + 文件记忆（最稳）

```bash
./agent plan . "在上次 milestone 基础上，补充 xxx"
./agent milestone . --summary "完成了 xxx"
```

适合不想开 TUI、只靠 `ai-context` 接手的场景。

---

## Subagent（子 Agent）—— 能用，由 Cursor 调度

ide-toolbox **没有单独的「subagent 开关」**。Subagent 是 **Cursor Agent 内置能力**：

- 父 Agent 通过 **Task 工具** 派发 explore / bash / browser 等内置子 Agent
- 你可在项目 `.cursor/agents/` 或 `~/.cursor/agents/` 定义**自定义子 Agent**
- 父 Agent 根据 `description` 自动委派，或在交互会话里用 `/agent-name`

### ide-toolbox 自带示例子 Agent

`.cursor/agents/handoff-reviewer.md` —— 只读审查 `ai-context` 是否足以移交。

在 **chat/continue 交互会话**里可以说：

```text
请用 handoff-reviewer 审查 docs/ai-context.md 是否可移交
```

### 使用条件（Cursor 侧）

| 条件 | 说明 |
|---|---|
| Cursor 版本 | 建议 2.4+ / 2.5+ |
| Task 工具 | 子 Agent 依赖 Task 工具；部分旧 CLI 版本可能没有 |
| Max Mode | 部分模型/计划下子 Agent 行为更完整 |
| 交互会话 | `chat` / `continue` 比单次 `--print` 更适合触发子 Agent |

### Plan 模式 vs Subagent

- **Plan 模式**：限制**当前 Agent** 不改文件（只读规划）
- **Subagent**：**另一个 Agent** 处理子任务（可 readonly 或并行）
- 二者可同时存在：父 Agent 在 plan 模式下仍可派发 readonly 子 Agent 做代码库搜索

### 与 IDE 图形界面的差异

| 能力 | IDE 聊天 | `./agent chat/continue` | `./agent plan`（单轮） |
|---|---|---|---|
| 连续追问 | 原生 | 原生（TUI） | 需新开命令 |
| Plan 模式 | 有 | `--mode plan` | 默认 |
| Subagent | 有 | 有（取决于 Cursor CLI） | 可能有，但单轮很快结束 |
| 写回 ai-context | 需手动/milestone | milestone 收尾 | milestone 收尾 |

---

## Milestone 写回验证（tool 自动做）

`./agent milestone .` 现在会：

1. 运行前记录 `ai-context.md` 指纹
2. 让 Agent **必须改文件**（见 prompt 模板）
3. 运行后检查文件是否变化、Last Session 日期是否为今天
4. 可选 `--summary "摘要"` 由脚本 **确定性写入** Last Session

```bash
./agent milestone . --summary "完成 agent-cli chat/continue 与写回验证"
```

若 Agent 只在回复里总结、没改文件，会看到 WARN 和补救命令。

---

## 推荐工作流

```text
接手/讨论     →  ./agent chat .          # 或多轮 continue
只读方案      →  ./agent plan . "..."
改文件        →  ./agent run . "..." --execute
阶段结束      →  ./agent milestone . --summary "..."
审查移交      →  在 chat 里请 /handoff-reviewer
```

---

## 相关配置（project-policy.yaml）

```yaml
agent_cli:
  default_mode: "plan"
  allow_continue: true
  milestone_verify_writeback: true
  allow_execute: false
```

---

## 相关文档

- [agent-cli-self-maintenance.md](agent-cli-self-maintenance.md)
- [scripts-reference.md](scripts-reference.md)
- [Cursor Subagents 官方文档](https://cursor.com/docs/subagents)
