# AI Runbook — {{PROJECT_NAME}}

## Start A Session

1. Confirm working directory is correct.
2. Run `git status --short --branch` if Git is available.
3. Read `AGENTS.md` and `docs/ai-context.md`.

## Safe Change Pattern

1. State intended files and impact.
2. Make the smallest useful change.
3. Verify by reading changed files or running checks.
4. Summarize in Chinese.
5. Give a suggested commit message.

## High-Risk Actions

Pause and ask for confirmation before:

- Deleting or overwriting important files
- Moving or archiving directories
- Changing permissions or secrets
- Installing dependencies
- Exposing ports
- Git push or remote changes
- Database, cache, or Docker volume changes

## Long-Running Work

1. Break work into named stages.
2. Keep irreversible actions out of unattended stages.
3. Record durable findings in project files.
4. Do not claim completion until evidence is checked.

## Rollback

Revert the specific files listed in the work summary, or use Git if the project is under version control.
