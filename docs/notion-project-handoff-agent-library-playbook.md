# Notion 双轨项目移交与 Agent Library 接线 Playbook

## 适用场景

当一个项目同时使用本地 Markdown/Git 与 Notion 页面/数据库时，用本 playbook 保证 AI 接手、任务执行、里程碑收尾和跨项目复用都不依赖聊天记录。

适用于：

- Notion 任务库、日历、打卡清单、资料库
- 本地保存 SOP、manifest、CSV 镜像的双轨项目
- 需要后续 Agent 无缝接手的长期维护项目

不适用于：

- `private-local` 且不允许共享任何上下文的项目
- 只有一次性聊天、不打算维护文件状态的临时任务
- 已经有独立数据库同步系统且不使用本地 manifest 的项目

## 核心原则

1. Notion 是执行界面，本地文件是 AI 接手真相源。
2. 结构变更先写本地，再改 Notion。
3. 状态勾选以 Notion 为准，必要时回写 CSV 镜像。
4. 聊天不是长期记忆，阶段结束必须写回 `docs/ai-context.md`。
5. 可复用模式先留在项目内，第二个不同项目仍需要时再去敏晋升。

## 新项目默认文件

Notion 双轨模板至少应包含：

- `AGENTS.md`：Agent 会话启动规则
- `docs/ai-context.md`：Current State、Last Session、Recent Decisions
- `docs/HANDOFF.md`：5 分钟接手路径
- `docs/notion-sync-policy.md`：本地/Notion 分工
- `docs/agent-library.md`：共享资产库策略
- `docs/suggested-assets.md`：自动匹配到的可复用资产
- `manifest.yaml`：本地路径和 Notion 页面/数据库映射
- `NOTION_INDEX.md`：人类可读 Notion 索引
- `data/*.csv`：数据库镜像
- `.cursor/rules/*.mdc`：项目级自动规则

## 会话启动流程

Agent 开始前按顺序读取：

1. `AGENTS.md`
2. `docs/ai-context.md`
3. `docs/HANDOFF.md`
4. `docs/notion-sync-policy.md`
5. `manifest.yaml`
6. `NOTION_INDEX.md`
7. `docs/suggested-assets.md`
8. 相关 `data/*.csv`

如果用户请求直接改 Notion，先确认：

- 要改的是结构、内容还是状态
- 本地真相源需要同步哪些文件
- 是否涉及隐私、删除、覆盖、权限、密钥或外部发布

## 执行规则

### 结构变更

先更新：

- `docs/`
- `manifest.yaml`
- `NOTION_INDEX.md`

再创建或修改 Notion 页面/数据库。

### 长文或 SOP

先在 `content/` 或 `docs/` 写源稿，再同步到 Notion 页面。不要只把长文留在 Notion 或聊天里。

### 任务状态

状态以 Notion 为准。若本地有 `data/*.csv` 镜像，完成后回写关键字段。

### 链接和 ID

Notion URL、页面标题、数据库映射必须写入 `manifest.yaml` 和 `NOTION_INDEX.md`。不要只存在聊天记录里。

## 里程碑收尾

每个阶段结束前：

1. 更新 `docs/ai-context.md` 的 Current State。
2. 更新 Last Session，写清楚本次完成、下一步和风险。
3. 追加 `CHANGELOG.md`。
4. 运行项目体检。
5. 运行 `session-handoff.sh`。
6. 判断是否有可复用模式需要晋升。

## 体检检查点

`project-health.sh` 对 Notion 项目至少检查：

- Git 状态和 remote
- `manifest.yaml`、`NOTION_INDEX.md`
- `docs/ai-context.md`
- `docs/HANDOFF.md`
- `docs/notion-sync-policy.md`
- `docs/agent-library.md`
- `docs/suggested-assets.md`
- `data/tasks-master.csv` 或等价数据镜像
- Last Session 是否仍是 `(none yet)`
- `ai-context` 是否仍有“待填写”
- Agent Library 是否可达

## 旧项目升级

旧 Notion 项目升级时只补缺失文件，不覆盖已有内容。

建议顺序：

1. `upgrade-ai-project.sh /path/to/project --dry-run`
2. 检查将创建的文件
3. 确认无覆盖后执行升级
4. `project-health.sh /path/to/project`
5. 按 WARN 修补 `ai-context`、manifest、Notion 索引

## Agent Library 晋升规则

值得晋升的内容：

- Notion 双轨搭建 SOP
- 通用日历/打卡/任务库结构
- manifest 与 Notion 索引维护规则
- session-handoff 里程碑模板
- 体检检查点和旧项目升级策略

不得晋升的内容：

- 真实 Notion URL、page_id、data_source_id
- 个人计划、健康、签证、求职等实例数据
- GitHub 私有仓库 URL
- 设备绝对路径
- `private-local` 项目内容

晋升前必须把项目实例改成通用表达，例如：

- “健身打卡项目” → “任意 Notion 维护项目”
- “某个真实 Notion Hub” → “Notion Hub”
- “某个本地绝对路径” → `/path/to/project`

## 用户口令

```text
先按 AGENTS.md 接手这个 Notion 项目，不要先改文件。说明你会读取哪些文件、当前状态是什么、有哪些 suggested-assets。
```

```text
按长跑模式执行：先给计划，再修改本地和 Notion，最后验证。结束前更新 ai-context。
```

```text
这是一个里程碑。请按 session-handoff 收尾：更新 ai-context，列出已完成、下一步、验证方式、回滚方式和建议 commit message。
```

```text
评估这次产出是否值得晋升到 Agent Library。若值得，先说明去敏方案。
```
