# ContextDocs

## Identity

ContextDocs is a Claude Code plugin for generating, maintaining, and auditing AI IDE context files. Pure Markdown, zero runtime dependencies. Applies the Signal Gate principle — only includes what agents cannot discover on their own.

## Available Skills

Skills are loaded on-demand. Each lives at `.claude/skills/<name>/SKILL.md`. There are 3 skills in total.

| Skill | What It Provides |
|-------|-----------------|
| `ai-context` | AI IDE context file generation with Signal Gate principle — 7 context file types from codebase analysis, init/update/promote/audit lifecycle |
| `context-guard` | Context Guard hook installation — two-tier enforcement, settings.json configuration, troubleshooting *(Claude Code only)* |
| `context-verify` | Context file validation — line budgets, discoverable content detection, stale paths, cross-file consistency, 0–100 health scoring with CI integration |

## Workflow Commands

Invoke as `/contextdocs:command-name` in Claude Code, or as prompts in Codex CLI and OpenCode.

| Command | What It Does |
|---------|-------------|
| `ai-context` | Generate AI context files using Signal Gate — supports `all`, `claude`, `agents`, `cursor`, `copilot`, `windsurf`, `cline`, `gemini`, `init`, `update`, `promote`, `audit` |
| `context-guard` | Install, uninstall, or check status of Context Guard hooks with tiered enforcement *(Claude Code only)* |
| `context-verify` | Validate context file quality — line budgets, stale paths, consistency, health scoring, CI integration |

## Rules (Claude Code Only)

- `context-quality.md` — cross-file consistency, path verification, version accuracy, sync points (auto-loaded)
- `context-awareness.md` — context trigger map, suggests ContextDocs commands when relevant (auto-loaded)

## Hooks (Claude Code Only)

5 opt-in hooks, installed via `/contextdocs:context-guard install`:

- `context-drift-check.sh` — post-commit drift detection
- `context-structural-change.sh` — structural change reminders
- `content-filter-guard.sh` — Write guard for high-risk OSS files
- `context-guard-stop.sh` — session-end context doc nudge (Tier 1)
- `context-commit-guard.sh` — pre-commit context doc enforcement (Tier 2)
