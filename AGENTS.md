# ContextDocs

## Identity

ContextDocs is a Claude Code plugin for generating, maintaining, and auditing AI IDE context files. Pure Markdown, zero runtime dependencies. Applies the Signal Gate principle — only includes what agents cannot discover on their own.

Generated project context follows an AGENTS-first model: `AGENTS.md` carries the shared conventions, commands, and constraints, while `CLAUDE.md`, `.cursorrules`, Copilot instructions, `.clinerules`, `.windsurfrules`, and `GEMINI.md` stay thin bridges. For Claude Code, `CLAUDE.md` is auto-loaded every session and uses `@AGENTS.md` to import the canonical shared context. Other tools (Codex CLI, Gemini CLI, OpenCode) load `AGENTS.md` directly at startup.

## Agent

| Agent | What It Does |
|-------|-------------|
| `context-updater` | Autonomously updates stale AI context files with an AGENTS-first workflow — updates shared context in `AGENTS.md`, then refreshes only affected bridge files. Capped at 10 turns, no internet access *(Claude Code only)* |
| `docs-freshness` | Read-only documentation freshness checker — detects stale docs, version mismatches, missing files, suggests `/pitchdocs:*` commands to fix. Capped at 8 turns, enforces read-only via disallowedTools *(PitchDocs, Claude Code only)* |

## Available Skills

Skills are loaded on-demand. Each lives at `.claude/skills/<name>/SKILL.md`. There are 3 skills in total.

| Skill | What It Provides |
|-------|-----------------|
| `ai-context` | AGENTS-first AI IDE context generation — builds canonical `AGENTS.md`, then emits thin bridges for Claude, Copilot, Cursor, Windsurf, Cline, and Gemini, with init/update/promote/audit lifecycle support |
| `context-guard` | Context Guard hook installation — two-tier enforcement, SessionStart health check, settings.json configuration, companion reference for 17 hook events and 4 handler types, troubleshooting *(Claude Code only)* |
| `context-verify` | Context file validation — line budgets, discoverable content detection, stale paths, @import validation, rule path-scope and symlink checks, .mcp.json validation, agent memory hygiene, plugin manifest completeness, AGENTS-to-bridge consistency, aggregate context load, and 0–100 health scoring with CI integration |

## Workflow Commands

Invoke as `/contextdocs:command-name` in Claude Code, or as prompts in Codex CLI and OpenCode.

| Command | What It Does |
|---------|-------------|
| `ai-context` | Generate AGENTS-first AI context using Signal Gate — supports `all`, `claude`, `agents`, `cursor`, `copilot`, `windsurf`, `cline`, `gemini`, `init`, `update`, `promote`, `audit` |
| `context-guard` | Install, uninstall, or check status of Context Guard hooks with tiered enforcement *(Claude Code only)* |
| `context-verify` | Validate context file quality — line budgets, stale paths, bridge consistency, health scoring, CI integration |

## Rules (Claude Code Only)

- `context-quality.md` — AGENTS-first bridge consistency, path verification, version accuracy, sync points (auto-loaded)
- `context-awareness.md` — context trigger map, suggests ContextDocs commands when relevant (auto-loaded)
- `doc-standards.md` — documentation quality standards, 4-Question Test, Lobby Principle, banned phrases (auto-loaded, PitchDocs)
- `docs-awareness.md` — documentation trigger map, suggests PitchDocs commands when docs-relevant work is detected (auto-loaded, PitchDocs)

## Hooks (Claude Code Only)

7 opt-in hooks, installed via `/contextdocs:context-guard install`. Hooks reference the context-updater agent for autonomous action:

- `context-session-start.sh` — session-start context health check (advisory)
- `context-forced-eval.sh` — keyword-gated skill evaluation on context-related prompts (advisory)
- `context-drift-check.sh` — post-commit drift detection
- `context-structural-change.sh` — structural change reminders to update `AGENTS.md` first, then bridges
- `content-filter-guard.sh` — Write guard for high-risk OSS files
- `context-guard-stop.sh` — session-end context doc nudge (Tier 1)
- `context-commit-guard.sh` — pre-commit context doc enforcement (Tier 2)
