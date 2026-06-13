# 维护手册

面向“以后你自己或 Agent 改工具箱”的说明。

## 修改前原则

1. 先 `git status`（若工具箱已纳入 Git）
2. 不改 `00_FileStation` 里的业务项目，除非明确任务需要
3. 高风险改动前说明：目的、影响、回滚
4. 改完后更新 [changelog.md](changelog.md)

## 常见维护任务

### 新增 `./ide` 菜单项

1. 在 `scripts/ide.sh` 的 `MAIN_MENU_ITEMS` 追加功能项（`dispatch_home_choice` 中 `main_idx` 从 11 起递增）
2. 添加 `action_xxx` 函数，并在 `dispatch_home_choice` 的 `case "$main_idx"` 中映射
3. 若需改快速打开逻辑，改 `build_home_menu_options` / `list_recent_projects`（`lib.sh`）
4. 交互 UI 在 `scripts/interactive-menu.py`（`[N]` 显示编号）
5. 同步 [scripts-reference.md](scripts-reference.md)、[automation-playbook.md](../automation-playbook.md)、[README.html](../README.html)

### 修改新项目模板

编辑 `templates/ai-project/` 或 `templates/notion-project/` 下文件：

| 文件 | 何时改 |
|---|---|
| `AGENTS.md` | 项目 Agent 启动清单 |
| `docs/ai-context.md` | 项目上下文结构 |
| `docs/runbook.md` | 长跑/交接流程 |
| `docs/devices.md` | 设备台账格式 |
| `.cursor/rules/*.mdc` | Cursor 项目规则 |
| `.gitignore` | 默认忽略规则 |

改完后用 dry-run 验证：

```bash
./scripts/new-ai-project.sh test-template-check --dry-run
```

**注意**：已存在项目不会自动更新，需用 `upgrade-ai-project.sh`（只补缺失）。

### 修改隐私策略

编辑 `config/project-policy.yaml` 的 `privacy_profiles`，并同步：

- `scripts/lib.sh` 中 `privacy_profile_*` 函数
- `scripts/new-ai-project.sh` 限制逻辑
- [scripts-reference.md](scripts-reference.md)

### 修改存储路径

编辑 `config/project-policy.yaml`：

- `paths.*`：通用路径
- `devices.*`：分设备路径

改完后运行：

```bash
./scripts/check-device.sh
```

### 修改归档规则

编辑 `config/project-policy.yaml` 的 `archive.archive_subdir`，默认 `99_归档`。

### 新增脚本

1. 在 `scripts/` 创建 `xxx.sh`
2. `source lib.sh`
3. 支持 `--help` 和 `--dry-run`（如适用）
4. `chmod +x`
5. 视需要接入 `ide.sh`
6. 更新 [scripts-reference.md](scripts-reference.md)

## 配置项速查

| 配置键 | 含义 |
|---|---|
| `paths.active_projects` | NAS 挂载活动根（回退用） |
| `paths.active_projects_cursor_sync` | MacBook Drive 同步根 |
| `paths.active_projects_windows_sync` | Windows Drive 同步根 |
| `devices.macbook.active_projects` | MacBook 推荐路径（Drive 同步） |
| `devices.macmini.active_projects` | Mac mini 推荐路径（NAS 挂载） |
| `devices.windows.active_projects` | Windows 活动目录（Drive 同步） |
| `paths.archive_projects` | 归档根目录（NAS 挂载） |
| `recent_projects.limit` | 最近项目显示上限（默认 5） |
| `recent_projects.max_age_days` | 最近项目天数筛选（默认 7） |
| `privacy_profiles.*` | 隐私与 GitHub 策略 |
| `github.default_visibility` | 默认是否建远程 |
| `archive.default_dry_run` | 归档是否默认预览 |

## 文档维护清单

每次功能变更后，检查是否需更新：

- [ ] README.md
- [ ] README.html
- [ ] AGENTS.md
- [ ] automation-playbook.md
- [ ] storage-policy.md
- [ ] docs/architecture.md
- [ ] docs/scripts-reference.md
- [ ] docs/onboarding.md
- [ ] docs/troubleshooting.md
- [ ] docs/changelog.md

## 回滚工具箱改动

若工具箱尚未纳入 Git：

- 删除本次新增文件
- 用备份还原被改文件

建议将 `ide-toolbox` 本身纳入 GitHub repo，便于跨设备同步和回滚。

## 建议 commit message

```text
docs: add toolbox documentation set
feat: add ide menu item for ...
fix: correct device profile detection on macOS
```
