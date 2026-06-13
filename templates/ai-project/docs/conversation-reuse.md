# Conversation Reuse — {{PROJECT_NAME}}

Use this file to preserve reusable decision logic from important Cursor/Codex conversations.

## What To Preserve

- User goal
- Constraints
- Decision framework
- Final operating rule
- Open risks
- Rollback path

## Capture Template

```markdown
## Conversation Capture

### Goal

### Constraints

### Decision Logic

### Project-Level Memory

### User-Level Memory Candidate

### Verification

### Rollback
```

## Reusable Prompt

```text
请不要只依赖本次聊天记录。请把这次对话中可复用的决策逻辑沉淀到项目文件里：
1. 哪些是项目级规则
2. 哪些是我的通用工作偏好
3. 长时间放任 Agent 执行时，需要哪些阶段、停止条件、验证方式和回滚方式
4. 最后告诉我改了哪些文件、为什么改、如何验证、如何回滚
```

## Agent Library 晋升评估

会话结束前自问：

- 本次产出是否在**第二个不同项目**中仍会有用？
- 是否已去除路径、密钥、证件等敏感信息？
- 若是 → 使用 ide-toolbox `promote-agent-asset.sh` 或 `./ide` → 晋升资产到库
- 若否 → 仅保留在本项目 `docs/` 内

`private-local` 项目**永不**晋升到 `05_Agent-Library`。
