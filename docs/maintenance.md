# 维护手册

面向“以后你自己或 Agent 改工具箱”的说明。

## 修改前原则

1. 先 `git status`（若工具箱已纳入 Git）
2. 不改 `00_FileStation` 里的业务项目，除非明确任务需要
3. 高风险改动前说明：目的、影响、回滚
4. 改完后更新 [changelog.md](changelog.md)

## 常见维护任务

### 新增 `./ide` 菜单项

1. 在 `scripts/ide.sh` 添加 `action_xxx` 函数
2. 更新 `show_main_menu` / `show_path_menu`
3. 更新 `run_main_choice` / `run_path_choice`
4. 同步 [scripts-reference.md](scripts-reference.md) 和 [automation-playbook.md](../automation-playbook.md)

### 修改新项目模板

编辑 `templates/ai-project/` 下文件：

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
| `paths.active_projects` | 活动项目根目录 |
| `paths.archive_projects` | 归档根目录 |
| `devices.windows.active_projects` | Windows 活动目录 |
| `privacy_profiles.*` | 隐私与 GitHub 策略 |
| `github.default_visibility` | 默认是否建远程 |
| `archive.default_dry_run` | 归档是否默认预览 |

## 文档维护清单

每次功能变更后，检查是否需更新：

- [ ] README.md
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

建议尽快将 `ide-toolbox` 本身初始化为 private GitHub repo，便于跨设备同步和回滚。

## 建议 commit message

```text
docs: add toolbox documentation set
feat: add ide menu item for ...
fix: correct device profile detection on macOS
```
