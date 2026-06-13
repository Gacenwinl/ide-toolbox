# AI Context — IDE Toolbox

## Purpose

Cursor/Codex 多端项目的**自动化工具箱**（治理层）：`./ide` 入口、项目模板、升级/体检/归档脚本。

## Privacy Profile

- Profile: `automation`（工具箱自身）
- GitHub：已使用 public repo（`Gacenwinl/ide-toolbox`），不含业务项目敏感数据

## Source Of Truth

| 文件 | 用途 |
|---|---|
| `AGENTS.md` | Agent 入口 |
| `README.md` / `README.html` | 人类总览 |
| `storage-policy.md` | 多端路径策略（MacBook/Win 同步 · Mac mini 挂载） |
| `docs/runbook.md` | 维护长跑与安全 |
| `config/project-policy.yaml` | 路径、设备、隐私策略 |
| `projects-index.md` | 业务项目台账 |
| `docs/changelog.md` | 工具箱变更记录 |

## 与业务项目模板的差异

工具箱**不是** `templates/ai-project` 的副本，但遵循同一原则：

- 项目文件为记忆真相源
- `.cursor/rules/project-toolbox.mdc` 等同业务项目的 `.cursor/rules`
- 文档集中在 `docs/` + 根目录 playbook

## Handoff Checklist

维护工具箱后：

- [ ] 更新 `docs/changelog.md`
- [ ] 若影响用户总览，同步 `README.md` / `README.html` / `automation-playbook.md`
- [ ] 多轮对话收尾写 `docs/YYYYMMDD-*-followup.md`（见 `20260614-ide-toolbox-followup.md`）
- [ ] `bash -n scripts/*.sh`
- [ ] 说明验证与回滚（中文）

## 关联项目

- **NAS 结构优化**：`260613-nas-storage-optimize`（规划与迁移执行）
- **跟进沉淀**：`docs/20260614-ide-toolbox-followup.md`
