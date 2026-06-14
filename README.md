# IDE Toolbox — 项目自动化工具箱

> 可视化总览：用浏览器打开 [README.html](README.html)

Cursor/Codex 多端项目的统一启动与治理目录。日常入口：`./ide`。

## 快速开始

```bash
cd "/Users/dawncity/Library/CloudStorage/SynologyDrive-FileStation/ide-toolbox"
./ide
```

拖入项目路径（MacBook 示例，路径因设备而异）：

```bash
./ide ~/Library/CloudStorage/SynologyDrive-FileStation/260000-Job-Codex
```

路径策略：**MacBook / Windows = Synology Drive 同步 · Mac mini = NAS 挂载**。详见 [storage-policy.md](storage-policy.md)。

新设备第一次使用：先看 [docs/onboarding.md](docs/onboarding.md)

## 文档导航

| 文档 | 用途 |
|---|---|
| [docs/README.md](docs/README.md) | 文档总索引 |
| [docs/onboarding.md](docs/onboarding.md) | 新设备接入 |
| [docs/codex-onboarding.md](docs/codex-onboarding.md) | Codex 用户规则与接入 |
| [automation-playbook.md](automation-playbook.md) | 日常操作 |
| [storage-policy.md](storage-policy.md) | 存储策略（含群晖/Mac/Windows 路径对照） |
| [docs/architecture.md](docs/architecture.md) | 系统架构 |
| [docs/scripts-reference.md](docs/scripts-reference.md) | 脚本参考 |
| [docs/troubleshooting.md](docs/troubleshooting.md) | 故障排查 |
| [docs/maintenance.md](docs/maintenance.md) | 维护手册 |
| [docs/agent-cli-self-maintenance.md](docs/agent-cli-self-maintenance.md) | 关闭 Cursor IDE 后用 `./agent` 自维护 |
| [docs/changelog.md](docs/changelog.md) | 变更记录 |

## 核心能力

- `./ide` 单一入口：**1–10** 快速打开最近项目（≤5、7 天内）· **11+** 功能操作
- 新建 / 升级 / 体检 / 归档 / 对话沉淀
- 隐私分级：`private-local` 禁止 GitHub
- 设备接入检查 + 项目设备登记
- Codex 用户级规则模板（对齐 Cursor 项目级 rules）
- **Agent 复利**：`05_Agent-Library` + 新建项目自动 `suggested-assets.md`（见下节）
- **Agent CLI 自动驾驶**：`ide-toolbox` 可调用 `cursor agent` 进行接手、计划、执行、里程碑收尾
- 多端路径：**MacBook / Windows** Drive 同步 · **Mac mini** NAS 挂载（见 `storage-policy.md`）

## Agent 复利（Hub）

跨项目 Skill/playbook 不进聊天，而走：

1. **L1** 项目内 `docs/ai-context.md`（Current State / Last Session）
2. **L2** `02_Resources Files/05_Agent-Library` + `manifest.yaml`
3. **工厂**：`./ide` → 11) 新建项目 → 自动 `docs/suggested-assets.md`

```bash
./scripts/query-agent-assets.sh --task "任务关键词"
./scripts/promote-agent-asset.sh --project /path --source docs/x.md --id slug --title "标题"
./scripts/session-handoff.sh /path/to/project   # 会话结束检查
```

### 日常怎么用

1. 新建项目：`./ide` → **11) 新建多端 AI 项目**
2. 打开新项目：先读 `AGENTS.md`，再看 `docs/suggested-assets.md`
3. 做完一段 substantial 工作：更新 `docs/ai-context.md` 的 `Current State` / `Last Session`
4. 收尾检查：`./scripts/session-handoff.sh /path/to/project`
5. 第二次跨项目仍需要的 SOP/Skill：再用 `promote-agent-asset.sh` 或 `./ide` → **26) 晋升资产到库**

当前库内已包含 Notion 双轨项目移交 playbook：`notion-project-handoff-agent-library`，新建或升级 Notion 项目时会被 `query-agent-assets.sh` 匹配到。

不会后台自动总结所有聊天；它提供的是**自动结构 + 明确规则 + 收尾检查 + 手动确认晋升**。

详见 [storage-policy.md](storage-policy.md) §05、[docs/ai-context.md](docs/ai-context.md)。

## Agent CLI 自动驾驶

如果不想打开 Cursor 图形界面，可以让 `ide-toolbox` 在命令行里调用 Cursor Agent CLI。

```bash
./scripts/agent-cli.sh start /path/to/project --dry-run
./scripts/agent-cli.sh plan /path/to/project "任务目标" --dry-run
./scripts/agent-cli.sh run /path/to/project "任务目标" --execute
./scripts/agent-cli.sh milestone /path/to/project --dry-run
./scripts/agent-cli.sh new-notion 260614-example --purpose "项目目标" --dry-run
```

它会自动组装项目上下文、查询 Agent Library、生成标准 prompt，并在执行后接入 `project-health.sh` / `session-handoff.sh`。默认不使用 `--force` / `--yolo`；删除、覆盖、权限、密钥、Git push、Notion 大规模结构修改仍需要确认。

根目录快捷入口：`./agent`（等同 `scripts/agent-cli.sh`）。关闭 Cursor IDE 后的完整流程见 [docs/agent-cli-self-maintenance.md](docs/agent-cli-self-maintenance.md)。

## 项目全生命周期怎么用

这套工具的目标不是替你“自动想清楚一切”，而是让每个项目从创建到结束都有固定入口、固定记忆、固定收尾检查。你只需要在关键阶段对 AI 说清楚口令，并让它按项目文件写回。

### 0. 创建前：先定项目类型和隐私

先想清楚三件事：

| 问题 | 例子 |
|---|---|
| 这个项目解决什么问题？ | “整理法国签证材料流程” / “开发一个自动化脚本” |
| 项目类型是什么？ | `code` / `docs` / `knowledge` / `automation` |
| 隐私级别是什么？ | 普通项目用 `code`/`knowledge`；证件、签证、求职资料用 `private-local` |

对 AI 可以说：

```text
用 ide-toolbox 新建一个项目，名字叫 260614-xxx，类型是 knowledge，用途是 xxx，隐私策略是 private-local。
```

或自己运行：

```bash
./ide
# 11) 新建多端 AI 项目
```

创建后你应该看到：

- `AGENTS.md`：AI 接手入口
- `docs/ai-context.md`：项目状态与长期记忆
- `docs/runbook.md`：长跑与验证方式
- `docs/agent-library.md`：共享资产库策略
- `docs/suggested-assets.md`：自动匹配到的可复用资产（`private-local` 会跳过）

Notion 维护项目也一样会生成 `docs/ai-context.md`、`docs/agent-library.md`、`docs/suggested-assets.md`。它额外使用 `docs/HANDOFF.md`、`manifest.yaml`、`NOTION_INDEX.md` 和 `data/*.csv` 做 Notion 双轨接手，不再需要手动补这些移交规则。

### 1. 开始项目：让 AI 先接手，不要直接干活

打开项目目录后，先对 AI 说：

```text
先按 AGENTS.md 接手这个项目。请说明你会读取哪些文件、当前项目状态是什么、有哪些 suggested-assets，不要先改文件。
```

AI 应该读取：

1. `AGENTS.md`
2. `docs/ai-context.md`
3. `docs/runbook.md`（普通 AI 项目）或 `docs/HANDOFF.md`（Notion 维护项目）
4. `docs/agent-library.md`
5. `docs/suggested-assets.md`（非 `private-local`）

如果它没读这些文件，就让它停下：

```text
先不要继续。请按 ide-toolbox 的项目接手流程读取 AGENTS、ai-context、runbook 和 suggested-assets。
```

### 2. 开展任务：每一段工作都要有验证和写回

做具体任务时，对 AI 说：

```text
按长跑模式执行这个任务：先给计划，再修改，最后验证。结束前必须更新 docs/ai-context.md 的 Current State / Last Session。
```

如果任务可能复用已有经验，可以加一句：

```text
开始前先查一下 Agent Library 有没有适合这个任务的共享技能。
```

AI 应该做：

- 先检查 Git 状态
- 按任务读取项目文件
- 必要时运行 `query-agent-assets.sh`
- 修改后验证
- 把结果写回 `docs/ai-context.md` 或新建 `docs/YYYYMMDD-*.md`

### 3. 里程碑结束：做一次可移交收尾

每完成一个阶段，例如“初版完成”“资料整理完成”“脚本能跑通”，对 AI 说：

```text
这是一个里程碑。请按 session-handoff 收尾：更新 ai-context，列出已完成、下一步、验证方式、回滚方式和建议 commit message。
```

或自己运行：

```bash
./scripts/session-handoff.sh /path/to/project
```

如果有 WARN，先让 AI 修：

```text
session-handoff 有 WARN，请先补齐项目记忆，不要继续开发新功能。
```

里程碑收尾后，`docs/ai-context.md` 至少应该写清楚：

- Current State：现在做到哪
- Last Session：上次做了什么
- Recent Decisions：本阶段形成了什么规则
- Open Items：下一步是什么

### 4. 判断是否晋升到 Agent Library

不是所有东西都进共享库。只有当某个 SOP / checklist / prompt / 技能在**第二个不同项目**里也有用，才晋升。

对 AI 说：

```text
评估这次产出是否值得晋升到 Agent Library。若值得，请先说明会去除哪些项目私有信息，再准备 promote。
```

确认后再做：

```text
把这个已去敏的 playbook 晋升到 Agent Library。
```

或运行：

```bash
./scripts/promote-agent-asset.sh \
  --project /path/to/project \
  --source /path/to/project/docs/some-playbook.md \
  --id some-playbook \
  --title "某个可复用流程"
```

`private-local` 项目不要晋升。

### 5. 项目结束：归档前先保证可读、可回滚

项目结束或暂停前，对 AI 说：

```text
这个项目准备结束/暂停。请做最终收尾：项目体检、session-handoff、整理 README/ai-context，说明如何恢复、如何归档、是否有可晋升资产。
```

建议检查：

```bash
./scripts/project-health.sh /path/to/project
./scripts/session-handoff.sh /path/to/project
```

确认无误后，再通过 `./ide` 做归档预览：

```bash
./ide /path/to/project
# 10) 归档预览
# 11) 归档执行（需要确认）
```

### 6. 最常用口令

| 场景 | 你对 AI 说 |
|---|---|
| 新建项目 | “用 ide-toolbox 新建一个项目，名字叫 xxx，类型是 xxx，用途是 xxx” |
| 接手项目 | “先按 AGENTS.md 接手，不要改文件，说明你会读哪些文件” |
| 开始任务 | “按长跑模式执行：计划、修改、验证、写回 ai-context” |
| 查复利库 | “查一下 Agent Library 有没有适合这个任务的共享技能” |
| 里程碑收尾 | “按 session-handoff 收尾，更新 ai-context 和下一步” |
| 晋升资产 | “评估这次产出是否值得晋升到 Agent Library” |
| 项目结束 | “做最终收尾：体检、handoff、归档建议、回滚方式” |

### 7. 最小原则

- **聊天不是记忆**：重要结论必须写进项目文件
- **自动结构不等于自动总结**：每个阶段结束要明确要求 AI 写回
- **先项目内，后共享库**：第一次产出留在项目；第二次跨项目需要才晋升
- **private-local 永不进共享库**
- **有 WARN 先修 WARN，不继续扩功能**

## 验证

```bash
bash -n scripts/*.sh
./scripts/check-device.sh
./scripts/batch-upgrade.sh --dry-run
```

## 回滚

删除工具箱内新增文件即可；不影响 `00_FileStation` 业务项目。详见 [docs/maintenance.md](docs/maintenance.md)。
