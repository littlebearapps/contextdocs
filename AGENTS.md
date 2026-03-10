# ContextDocs

Generate, maintain, and audit AI IDE context files (AGENTS.md, CLAUDE.md, .cursorrules, copilot-instructions.md, .windsurfrules, .clinerules, GEMINI.md) using the Signal Gate principle — only what agents cannot discover on their own. Includes Context Guard hooks for freshness enforcement, context verification scoring, and MEMORY.md promotion.

## Available Skills

Skills are loaded on-demand to provide deep reference knowledge. Each lives at `.claude/skills/<name>/SKILL.md`. There are 3 skills in total.

| Skill | What It Provides |
|-------|-----------------|
| `ai-context` | AI IDE context file generation with Signal Gate principle — AGENTS.md, CLAUDE.md, .cursorrules, copilot-instructions.md, .windsurfrules, .clinerules, GEMINI.md from codebase analysis. Includes init (bootstrap), update (incremental drift patching), promote (MEMORY.md → CLAUDE.md), and audit with Context Guard status |
| `context-guard` | Context Guard installation reference — hook architecture, settings.json configuration, two-tier enforcement, customisation, and troubleshooting *(Claude Code only)* |
| `context-verify` | Context file validation — line budget compliance, discoverable content detection, stale path scanning, cross-file consistency, MEMORY.md drift, and 0–100 health scoring with CI integration |

## Workflow Commands

These commands are defined in `commands/*.md` and can be invoked as slash commands in Claude Code and OpenCode, or as prompts in Codex CLI. Claude Code users: invoke as `/contextdocs:command-name`.

| Command | What It Does |
|---------|-------------|
| `ai-context` | Generate AI context files using Signal Gate — supports `all`, `claude`, `agents`, `cursor`, `copilot`, `windsurf`, `cline`, `gemini`, `init`, `update`, `promote`, `audit` |
| `context-guard` | Install, uninstall, or check status of Context Guard hooks with tiered enforcement *(Claude Code only)* |
| `context-verify` | Validate context file quality — line budgets, stale paths, consistency, health scoring, CI integration |

## Rules and Hooks (Claude Code Only)

- **Rules** (2): `.claude/rules/context-quality.md` (AI context file quality, auto-loaded), `.claude/rules/context-awareness.md` (context trigger map, auto-loaded)
- **Hooks** (5): `hooks/context-drift-check.sh` (post-commit drift detection), `hooks/context-structural-change.sh` (structural change reminders), `hooks/content-filter-guard.sh` (Write guard for high-risk OSS files), `hooks/context-guard-stop.sh` (session-end context doc nudge — Tier 1), `hooks/context-commit-guard.sh` (pre-commit context doc enforcement — Tier 2) — opt-in via `/contextdocs:context-guard install`
