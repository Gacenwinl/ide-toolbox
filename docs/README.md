# 文档索引

IDE Toolbox（`ide-toolbox`）工具箱文档入口。先看 [README.md](../README.md) 上手，按需深入本目录。

## 用户文档

| 文档 | 用途 |
|---|---|
| [../README.html](../README.html) | 可视化总览（浏览器打开，与 README.md 同步维护） |
| [../README.md](../README.md) | 文本总入口 |
| [onboarding.md](onboarding.md) | 新设备 5 分钟接入（Mac / Windows Git Bash / Mac mini） |
| [codex-onboarding.md](codex-onboarding.md) | Codex 用户规则配置与自检 |
| [codex-user-rule-template.md](codex-user-rule-template.md) | Codex 用户规则可复制正文 |
| [ai-context.md](ai-context.md) | 工具箱自身 AI 上下文 |
| [runbook.md](runbook.md) | 工具箱维护长跑手册 |
| [../automation-playbook.md](../automation-playbook.md) | 日常操作与 `./ide` 菜单 |
| [../storage-policy.md](../storage-policy.md) | NAS/Drive 存储分层与项目生命周期 |
| [troubleshooting.md](troubleshooting.md) | 常见问题与修复 |

## 开发 / 维护文档

| 文档 | 用途 |
|---|---|
| [architecture.md](architecture.md) | 系统架构与数据流 |
| [scripts-reference.md](scripts-reference.md) | 全部脚本参数、风险、输出 |
| [maintenance.md](maintenance.md) | 如何改菜单、模板、策略 |
| [changelog.md](changelog.md) | 工具箱版本变更记录 |

## 配置与索引

| 文件 | 用途 |
|---|---|
| [../config/project-policy.yaml](../config/project-policy.yaml) | 路径、设备、隐私、GitHub 策略 |
| [../projects-index.md](../projects-index.md) | 项目台账 |
| [../AGENTS.md](../AGENTS.md) | Cursor/Codex 打开工具箱时的 Agent 规则 |

## 推荐阅读顺序

**第一次使用**

1. onboarding.md
2. codex-onboarding.md（若使用 Codex）
3. automation-playbook.md
4. storage-policy.md

**长跑 Agent 前**

1. 运行 `./ide` → 项目体检
2. troubleshooting.md（如有 WARN）

**维护工具箱本身**

1. architecture.md
2. scripts-reference.md
3. maintenance.md
