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
