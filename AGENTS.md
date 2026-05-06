# ContextDocs

## Identity

ContextDocs is a Claude Code plugin for generating, maintaining, and auditing AI IDE context files. Pure Markdown, zero runtime dependencies. Applies the Signal Gate principle — only includes what agents cannot discover on their own.

Generated project context follows an AGENTS-first model: `AGENTS.md` carries the shared conventions, commands, and constraints, while `CLAUDE.md`, `.cursor/rules/agents.mdc`, optional Copilot instructions, `.clinerules/agents.md`, `.windsurfrules`, and `GEMINI.md` stay thin bridges. For Claude Code, `CLAUDE.md` is auto-loaded every session and uses `@AGENTS.md` to import the canonical shared context. Other tools (Codex CLI, Gemini CLI, OpenCode, Copilot's coding agent) load `AGENTS.md` directly at startup. Modern Cursor uses the `.cursor/rules/*.mdc` directory format with frontmatter; modern Cline uses the `.clinerules/` directory mode with optional path-scoped frontmatter. Legacy `.cursorrules` and flat `.clinerules` are preserved only when already present.

## Agent

| Agent | What It Does |
|-------|-------------|
| `context-updater` | Autonomously updates stale AI context files with an AGENTS-first workflow — updates shared context in `AGENTS.md`, then refreshes only affected bridge files. Capped at 10 turns, no internet access *(Claude Code only)* |
| `docs-freshness` | Read-only documentation freshness checker — detects stale docs, version mismatches, missing files, suggests `/pitchdocs:*` commands to fix. Capped at 8 turns, enforces read-only via disallowedTools *(PitchDocs, Claude Code only)* |

## Available Skills

Skills are loaded on-demand. Each lives at `.claude/skills/<name>/SKILL.md`. There are 3 skills in total.

| Skill | What It Provides |
|-------|-----------------|
| `ai-context` | AGENTS-first AI IDE context generation across 8 tools — builds canonical `AGENTS.md`, then emits thin bridges for Claude, Copilot (optional), Cursor (`.cursor/rules/*.mdc`), Windsurf, Cline (`.clinerules/` directory), and Gemini, with init/update/promote/audit lifecycle support and an opt-in six-section AGENTS.md scaffold |
| `context-guard` | Context Guard hook installation — two-tier enforcement, SessionStart health check, settings.json configuration with `if:` permission-rule matchers (v2.1.85+), companion reference for 17 hook events and 4 handler types, troubleshooting. Primary: Claude Code (12 events); cross-platform: Gemini CLI (11), Copilot (8), Cursor (4+), Cline (3) |
| `context-verify` | Context file validation — line budgets, discoverable content detection, stale paths, @import validation, rule path-scope and symlink checks, .mcp.json validation, agent memory hygiene, plugin manifest completeness, AGENTS-to-bridge consistency, aggregate context load, modern Cursor/Cline layout checks, Copilot bridge optionality, and 0–100 health scoring with CI integration across 16 checks. Also available as standalone CLI (`bin/context-verify.sh`) |

## Workflow Commands

Invoke as `/contextdocs:command-name` in Claude Code, or as prompts in Codex CLI and OpenCode.

| Command | What It Does |
|---------|-------------|
| `ai-context` | Generate AGENTS-first AI context using Signal Gate — supports `all`, `claude`, `agents`, `cursor`, `copilot`, `windsurf`, `cline`, `gemini`, `init`, `update`, `promote`, `audit`. Supports `--scaffold=six-section` flag on `init` for the GitHub Blog Apr 2026 six-section template (commands · testing · project structure · code style · git workflow · boundaries) |
| `context-guard` | Install, uninstall, or check status of Context Guard hooks with tiered enforcement — primarily Claude Code, with cross-platform hooks for Gemini CLI, Copilot, Cursor, and Cline. Uses `if: "Bash(git commit*)"` permission-rule matcher on commit-related hooks (v2.1.85+) |
| `context-verify` | Validate context file quality — 16 checks covering line budgets, stale paths, bridge consistency, modern Cursor/Cline/Copilot layouts, health scoring, CI integration |

## Rules (Claude Code Only)

- `context-quality.md` — AGENTS-first bridge consistency, path verification, version accuracy, sync points (auto-loaded)
- `context-awareness.md` — context trigger map, suggests ContextDocs commands when relevant (auto-loaded)
- `doc-standards.md` — documentation quality standards, 4-Question Test, Lobby Principle, banned phrases (auto-loaded, PitchDocs)
- `docs-awareness.md` — documentation trigger map, suggests PitchDocs commands when docs-relevant work is detected (auto-loaded, PitchDocs)

## Hooks

7 opt-in hooks for Claude Code, installed via `/contextdocs:context-guard install`. Adapted hooks for Gemini CLI, Copilot, Cursor, and Cline via `platforms/` packages (coming soon). For platforms without hooks, use `bin/context-verify.sh` as a CI-based alternative.

- `context-session-start.sh` — session-start context health check (advisory)
- `context-forced-eval.sh` — keyword-gated skill evaluation on context-related prompts (advisory)
- `context-drift-check.sh` — post-commit drift detection
- `context-structural-change.sh` — structural change reminders to update `AGENTS.md` first, then bridges
- `content-filter-guard.sh` — Write guard for high-risk OSS files
- `context-guard-stop.sh` — session-end context doc nudge (Tier 1)
- `context-commit-guard.sh` — pre-commit context doc enforcement (Tier 2)

## Synced Documentation Paths

These paths are consumed by external sync pipelines. Treat as protected — the upstream build fails if they go missing.

- `docs/faq/index.md` — FAQ scaffold for the help-centre FAQPage schema (issue #25). Synced to `littlebearapps.com/help/contextdocs/faq/` by the marketing-site `scripts/docs-sync.config.ts` mapping under `contextdocs`. **Do not delete or move.** **Update only when** an answer goes stale (new install path, retired feature, top support driver becomes a new question) — not on every release. Keep the question set lean: each H2 must end with `?`, every answer must be complete (no placeholders), and Australian English / banned-phrase rules from `.claude/rules/doc-standards.md` apply.
