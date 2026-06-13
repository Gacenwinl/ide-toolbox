# Agent Library — {{PROJECT_NAME}}

## 本项目策略

- Privacy Profile: `{{PRIVACY_PROFILE}}`
- Agent Library 路径: `{{AGENT_LIBRARY_PATH}}`

## 使用规则

- 会话启动：先读 `docs/suggested-assets.md`（若存在）
- 任务前：在项目根目录运行 `query-agent-assets.sh --task "<任务摘要>"`（或通过 ide-toolbox `./ide`）
- 第一次产出：只写回本项目 `docs/`
- 第二次跨项目仍需要：晋升到 `05_Agent-Library`（`promote-agent-asset.sh` 或 `./ide` → 晋升）

## private-local 例外

若本项目为 `private-local`：

- **禁止**读取 `05_Agent-Library`
- **禁止**将本项目产出晋升到共享库
- 仅使用项目内 `docs/` 与 Git

## 晋升纪律

1. 先在项目内验证可用
2. 第二个不同项目仍需要时再晋升
3. 晋升前去除路径、密钥、证件细节
