# Agent Library 使用与晋升纪律

## 四层记忆

- L1：项目内 `docs/`（第一次产出）
- L2：`05_Agent-Library` + manifest（第二次跨项目需要）
- L3：`~/.cursor/skills`、Codex User Rules（第三次仍高频）
- L0：ide-toolbox 工厂（新建项目自动挂钩）

## 查询

```bash
./scripts/query-agent-assets.sh --task "任务关键词" --type knowledge
./scripts/query-agent-assets.sh --purpose "项目目标" --output docs/suggested-assets.md
```

## 晋升

```bash
./scripts/promote-agent-asset.sh \
  --project /path/to/project \
  --source docs/my-doc.md \
  --id my-asset --title "标题" \
  --tags "tag1" --triggers "词1,词2"
```

## 纪律

1. 第一次只写回项目内
2. 第二次跨项目需要才晋升
3. 晋升前去敏（路径、密钥、证件）
4. `private-local` 永不进库
