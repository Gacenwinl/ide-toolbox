# 变更记录

ide-toolbox 工具箱自身变更，不是业务项目 changelog。

## 2026-06-14 — 稳定性收敛审计

### 修复

- `scripts/ide.sh`：同步备用 `run_main_choice` 编号映射，避免与真实主菜单漂移
- `scripts/project-health.sh`：修复 05 不可达分支中错误的 `handoff_warn` 调用

### 验证

- `bash -n scripts/*.sh`
- `./scripts/check-device.sh`
- `./scripts/session-handoff.sh . --dry-run`
- `./scripts/project-health.sh .`

## 2026-06-14 — 移交记忆收口 + session-handoff（全项目）

### 新增

- `session-handoff.sh`：检查 ai-context 待填写 / Last Session，会话结束清单
- `./ide` 主菜单与项目菜单：「会话收尾移交检查」
- 业务模板 `ai-context.md`：Current State / Last Session / Recent Decisions / Open Items
- 模板 `AGENTS.md`、rules：**会话结束必做**（禁止只留聊天）

### 更新

- `docs/ai-context.md`：复利主线 + 接手状态（工具箱自身可移交）
- `docs/20260614-ide-toolbox-followup.md` 收口
- `README.md` Agent 复利一节
- `project-health.sh`：移交友好性 WARN（待填写、Last Session）
- `capture-conversation.sh`：提示同步 ai-context + session-handoff

## 2026-06-14 — Agent Library 复利体系 + 工厂全接线

### 新增

- `init-agent-library.sh`、`query-agent-assets.sh`、`promote-agent-asset.sh`、`agent-library.py`
- `lib.sh`：`resolve_agent_library_dir`、`wire_agent_library`、晋升/挂钩检查
- 模板：`docs/agent-library.md`、`docs/suggested-assets.md`；AGENTS / rules / conversation-reuse 复利段落
- `./ide` 主菜单 24–26：查询库 / 晋升 / 初始化库；项目菜单 5–6：刷新 suggested / 晋升
- `config/project-policy.yaml`：`paths.agent_library*`、`agent_library.*`
- `batch-upgrade.sh` 报告缺 agent-library 挂钩；`project-health.sh` 检查 05 可达与 manifest

### 行为

- `new-ai-project.sh` 末尾 `wire_agent_library()`（`private-local` 跳过）
- `upgrade-ai-project.sh` 补齐 agent-library 文件并可选刷新 suggested-assets
- `capture-conversation.sh` 模板增加 Agent Library 晋升评估

## 2026-06-14 — 新立项 NAS 优化 + ide-toolbox 跟进沉淀

### 新增

- 业务项目 `260613-nas-storage-optimize`（knowledge）：`docs/storage-plan.md`、`docs/migration-checklist.md`
- `docs/20260614-ide-toolbox-followup.md` 收口未 commit/push 等待办

### 修复

- `new-ai-project.sh`：`COMMIT=true` 默认值，修复创建项目时 `unbound variable` 中断

## 2026-06-13 — 多端路径策略：MacBook 改 Drive 同步

### 配置

- `devices.macbook` → Synology Drive 同步路径（与 Windows 统一）
- `devices.macmini` → 保持 NAS 挂载
- 重写 `storage-policy.md` 推荐策略表；同步 onboarding、architecture、README、HTML 等

## 2026-06-13 — 文档全量同步（菜单 1-10/11+、Windows 路径）

### 更新

- `automation-playbook.md`、`docs/maintenance.md`、`docs/architecture.md`、`docs/troubleshooting.md`
- `docs/onboarding.md`、`README.md`、`README.html`
- `projects-index.md` 移除 `_示例_` 占位行
- `docs/maintenance.md` 文档清单增加 `README.html`

## 2026-06-13 — Windows Synology Drive 同步路径

### 配置

- `devices.windows`：`C:/Users/13555/SynologyDrive`（00 活动区同步根目录）
- `paths.active_projects_windows_sync` / `toolbox_windows_sync` 同步记录
- 更新 `storage-policy.md`、`docs/onboarding.md` 中的 Windows 示例

## 2026-06-13 — 最近项目限 5 + 固定编号 1-10 / 11+

### 变更

- 最近项目最多 **5 个**，且仅显示 **7 天内**有目录活动的项目（`recent_projects.max_age_days`）
- 主菜单编号固定：**1–10** 快速打开，**11+** 功能项（`[11]` 标签显示）
- `interactive-menu.py` 按显示编号提交（输入 `11` 可正确匹配功能项）
- 空槽位（如选 6 但仅 3 个项目）友好提示，不退出程序

### 修复

- 补全 `read_recent_policy_value`；`show_path_menu` 缺失导致已选项目时崩溃

## 2026-06-13 — 合一主菜单 + stdout 修复

### 修复

- Python 菜单 UI 改 stderr，修复「无效选项（空）」
- **1–10 直接打开最近项目**，11+ 为其他操作（去掉重复的「从最近项目选择」）

## 2026-06-13 — 交互菜单改用 Python3

### 修复

- 删除不可靠的 Bash 方向键实现
- 新增 `scripts/interactive-menu.py`（termios，支持 ↑↓ / jk / 数字+回车）
- 失败时自动回退 `plain_menu_select`；`IDE_MENU_PLAIN=1` 强制纯数字

## 2026-06-13 — 菜单修复 + 工具箱自身文档补齐

### 修复

- `interactive_menu_select`：`stty min 1` 修复方向键；数字需**回车确认**方可输入 10、11 等

### 新增

- `docs/ai-context.md`、`docs/runbook.md`、`docs/devices.md`、`docs/codex-handoff.md`、`docs/conversation-reuse.md`（工具箱自身）

### 更新

- `project-health.sh` 识别 IDE Toolbox 自身检查项
- `AGENTS.md`、`docs/scripts-reference.md`

## 2026-06-13 — 可视化 README.html

### 新增

- `README.html` 单文件可视化总览（渐变暗色主题、架构/能力/文档导航）

### 更新

- `README.md`、`docs/README.md` 增加 HTML 入口链接

## 2026-06-13 — Codex 用户规则与接入文档

### 新增

- `docs/codex-onboarding.md` Codex 接入指南
- `docs/codex-user-rule-template.md` 可复制用户级规则正文
- `templates/ai-project/docs/codex-handoff.md` 业务项目内 Codex 接手入口
- `./ide` 主菜单「Codex 接入与用户规则」

### 更新

- `templates/ai-project/AGENTS.md`、`docs/ai-context.md`
- `scripts/upgrade-ai-project.sh`、`scripts/project-health.sh`
- `docs/onboarding.md`、`docs/architecture.md`、`AGENTS.md`

## 2026-06-13 — 方向键菜单 + 多端存储文档补全

### 新增

- `interactive_menu_select`：主菜单 / 项目菜单 / 最近项目支持 ↑↓ + 数字双模式
- `storage-policy.md` 增加群晖 / Mac / Windows 路径对照与同步分工说明

### 更新

- `docs/onboarding.md`、`docs/scripts-reference.md`、`README.md`

## 2026-06-13 — Notion 项目模板 + Git 初始化

### 新增

- `templates/notion-project/` 本地 + Notion 双轨维护模板
- `./ide` 主菜单「新建 Notion 维护项目」
- `new-ai-project.sh` 支持 `--type notion-sync`
- `project-health.sh` 识别 Notion 项目并检查 manifest / NOTION_INDEX

### 更新

- `config/project-policy.yaml` 增加 `notion-sync` 类型
- `docs/scripts-reference.md`、`automation-playbook.md`

## 2026-06-13 — 项目重命名

- 目录名由 `IDE Management` 重命名为 `ide-toolbox`
- 显示名统一为 **IDE Toolbox**
- 入口命令保持 `./ide`

## 2026-06-13 — 文档体系补全

### 新增

- `docs/README.md` 文档索引
- `docs/architecture.md` 系统架构
- `docs/onboarding.md` 新设备接入
- `docs/scripts-reference.md` 脚本参考
- `docs/troubleshooting.md` 故障排查
- `docs/maintenance.md` 维护手册
- `docs/changelog.md` 本文件

### 更新

- `README.md` 指向 docs 目录
- `AGENTS.md` 增加文档阅读顺序
- `storage-policy.md` 统一入口为 `./ide`
- `automation-playbook.md` 链接脚本文档

## 2026-06-13 — 工具箱体验优化

### 新增

- `scripts/ide.sh` / `ide` 单一交互入口
- `scripts/project-health.sh` 项目体检
- `scripts/batch-upgrade.sh` 批量升级（默认 dry-run）
- `scripts/check-device.sh` 设备接入检查
- `scripts/register-device.sh` 项目设备登记
- `templates/ai-project/docs/devices.md` 设备台账模板

### 更新

- `scripts/lib.sh`：最近项目、设备 profile、隐私策略
- `scripts/ide.sh`：两级数字菜单
- `config/project-policy.yaml`：`devices`、`privacy_profiles`
- `scripts/new-ai-project.sh`：`--privacy`、`private-local` 禁止 GitHub

## 2026-06-13 — 项目自动化工具箱初版

### 新增

- `scripts/new-ai-project.sh`
- `scripts/upgrade-ai-project.sh`
- `scripts/capture-conversation.sh`
- `scripts/archive-project.sh`
- `templates/ai-project/` 标准模板
- `config/project-policy.yaml`
- `README.md`、`AGENTS.md`、`storage-policy.md`、`automation-playbook.md`

### 策略

- 活动项目在 `00_FileStation`
- 归档项目在 `01_Project Files`
- GitHub 可选，默认不 push
- 不自动安装依赖
