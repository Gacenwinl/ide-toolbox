# AI Context — {{PROJECT_NAME}}

## Purpose

{{PROJECT_PURPOSE}}

## Privacy Profile

- Profile: `{{PRIVACY_PROFILE}}`
- Policy: {{PRIVACY_DESCRIPTION}}

## Source Of Truth

- Session entry: `AGENTS.md`
- Project overview: `README.md`
- Runbook: `docs/runbook.md`
- Codex handoff: `docs/codex-handoff.md`
- Conversation reuse: `docs/conversation-reuse.md`
- Device ledger: `docs/devices.md`

## Cursor vs Codex

| Tool | How rules load |
|---|---|
| Cursor | `.cursor/rules/*.mdc` auto-applies + this file |
| Codex | User-level rule (toolbox template) + read this file and `docs/codex-handoff.md` each session |

## Multi-Device Workflow

1. Open this project on the current device.
2. Read `AGENTS.md` first.
3. Check Git status before broad edits.
4. Write durable decisions back into Markdown files.

## Handoff Checklist

Before ending substantial work, record:

- What changed
- Why it changed
- How to verify
- How to roll back
- Suggested commit message
