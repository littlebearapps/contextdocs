---
name: ai-context
description: Generates, updates, and audits AGENTS-first AI IDE context files. Builds canonical AGENTS.md plus thin bridges for Claude Code, Cursor (modern .cursor/rules/*.mdc), Copilot, Cline (.clinerules/ directory), Windsurf, Gemini CLI, Codex CLI, and OpenCode. Use for creating, regenerating, fixing, or promoting context files — not just checking them.
when_to_use: |
  Trigger phrases:
  - "create context files for this project" or "set up CLAUDE.md / AGENTS.md"
  - "my .cursorrules / .clinerules / GEMINI.md is out of date"
  - "add Cursor / Copilot / Cline / Gemini / Windsurf context"
  - "bootstrap AGENTS.md" or "generate AI context for this repo"
  - "promote MEMORY.md patterns to CLAUDE.md"
  - "audit context for drift" or "are my context files stale?"
  - "fix the context files" or "regenerate the context"
  - "migrate .cursorrules to .cursor/rules/*.mdc"
  - "switch .clinerules to directory mode"
  Skip when:
  - The user is debugging a runtime error unrelated to AI context
  - They are asking what context files do, not how to create them
  - The work is mid-flow on a non-context coding task
  - They want to validate without regenerating (use context-verify)
  - They want to install hooks (use context-guard instead)
---

# AI Context File Generator

## The Signal Gate

Research shows auto-generated context files **reduce** AI task success by ~3% and increase token costs by 20% (ETH Zurich, Feb 2026). Less is more.

**The test for every line:** Would removing this cause the AI to make a mistake? If not, cut it.

### Include (Non-Discoverable)

- Non-obvious conventions (import order, naming deviations, spelling locale)
- Hard constraints ("never use `any`", "always use `direnv exec`")
- Key commands (test, build, deploy, lint)
- Security rules and environment quirks

### Exclude (Discoverable)

Directory listings, dependency lists, architecture overviews, framework conventions, API patterns visible in source, key file tables — agents discover all of these by reading the codebase.

Describe the **end state** you want, not step-by-step instructions. Consider fixing root causes rather than documenting workarounds (Osmani, 2026).

## Line Budgets

| File | Target | Hard Max |
|------|--------|----------|
| AGENTS.md | Under 120 lines | 160 lines |
| CLAUDE.md bridge | 10-20 lines | 80 lines |
| Other bridge files | 10-20 lines | 60 lines |

## Supported Context Files

| File | Role | Purpose |
|------|------|---------|
| `AGENTS.md` | Canonical | Shared identity, commands, conventions, constraints, security notes, monorepo guidance |
| `CLAUDE.md` | Thin bridge | Claude-specific rules + `@AGENTS.md` import |
| `.cursor/rules/agents.mdc` | Modern Cursor (default) | Frontmatter `description`, `globs`, `alwaysApply`; body imports AGENTS.md |
| `.cursorrules` | Legacy Cursor | Only emitted if already present; ignored by current Cursor in Agent mode |
| `.github/copilot-instructions.md` | Optional | Copilot loads AGENTS.md natively (Aug 2025); only emit for tool-specific scoping |
| `.windsurfrules` | Compatibility | Windsurf rule activation/metadata only |
| `.clinerules/agents.md` | Modern Cline (default) | Directory mode; supports `paths:` frontmatter for path-scoped rules |
| `.clinerules` | Legacy Cline | Flat-file fallback when already present |
| `GEMINI.md` | Compatibility | Gemini-specific discovery or extension notes only |

Format details and frontmatter examples live in `SKILL-reference.md`.

**Context file vs memory:** Context files contain instructions *for* the agent (shared via git). Memory files (MEMORY.md, agent-memory/) are notes *by* the agent (local only). Promote recurring memory insights to the appropriate context file.

## Generation Workflow

1. **Detect project profile** — scan manifests for language, framework, test runner, linter, CI/CD
2. **Extract non-discoverable conventions** — import order, naming patterns, commands, security rules, environment quirks
3. **Generate `AGENTS.md` first** — all shared commands, conventions, rules, and security notes in one canonical file (~120 lines; omit Project Structure, architecture, dependency dumps, key-file tables)
4. **Generate bridge files** — apply the Signal Gate again. CLAUDE.md uses `@AGENTS.md` plus Claude-specific additions (`.claude/rules/` references, key file pointers, path-scoped guidance). Other bridges reference or subset AGENTS.md and add only tool-specific fields. Cline may add a `## Before Committing` checklist. `.windsurfrules` and `GEMINI.md` are compatibility bridges — keep them especially lean.

## Modes

### `init` — Bootstrap new project

Scan codebase, generate `AGENTS.md` plus bridges that don't already exist: `CLAUDE.md` (uses `@AGENTS.md`), `.cursor/rules/agents.mdc` (modern Cursor), `.windsurfrules`, `.clinerules/agents.md` (directory mode), `GEMINI.md`. Copilot bridge optional (Copilot loads AGENTS.md natively). Skip files that already exist. Offer Context Guard hooks (Claude Code only), run audit pass, report summary.

**Optional flag — `--scaffold=six-section`:** Generate AGENTS.md using the GitHub Blog Apr 2026 six-section template (commands · testing · project structure · code style · git workflow · boundaries). Opt-in only — existing files are not migrated.

### `update` — Incremental drift patching

Compare context file commits vs source commits. Classify changes (scripts → Commands, configs → Conventions, renames → paths). Update `AGENTS.md` first, then only the bridge files whose tool-specific sections or references changed. Apply surgical edits using Edit — preserve human customisations.

### `audit` — Staleness check

Check version accuracy, command accuracy, stale paths, bridge contradictions against `AGENTS.md`, new untracked conventions, MEMORY.md drift, Context Guard health.

### `promote` — MEMORY.md → CLAUDE.md

Find convention-like patterns in MEMORY.md ("Always", "Never", "Use", "Prefer"). Cross-reference against CLAUDE.md. Present candidates. Append promoted insights using Edit.

## AGENTS.md Spec & Anti-Patterns

Tracks [agents.md spec](https://github.com/agentsmd/agents.md) v1.0 via `upstream-versions.json`; `check-upstream` Action flags drift. Don't implement draft v1.1 until stable. Don't include discoverable content (trees, deps, architecture), framework docs, secrets, or session-specific state. Always curate auto-generated files.

## Platform Notes

**AGENTS.md auto-load:** Codex CLI, OpenCode, Cursor, Windsurf, Cline, and Copilot load AGENTS.md natively. Claude Code requires `@AGENTS.md` in CLAUDE.md. Gemini CLI is configurable via `context.fileName` in settings.json.

**Modern Cursor / Cline / Copilot (2026):** Cursor uses `.cursor/rules/*.mdc` with frontmatter; flat `.cursorrules` is ignored in Agent mode. Cline uses the `.clinerules/` directory with optional path-scoped frontmatter. Copilot's coding agent loads AGENTS.md natively (Aug 2025), so the Copilot bridge is optional. Format details and frontmatter examples live in `SKILL-reference.md`.

**Hooks:** Context Guard hooks are available on Claude Code (12 events), Gemini CLI (11), Copilot (8, preview), Cursor (4+), Cline (3), and Codex CLI (2, experimental). See the context-guard skill for per-platform setup.

**Standalone verification:** Run `bin/context-verify.sh` on any platform for 0-100 health scoring without a plugin system.

## Advanced Reference (Claude Code)

For agent/skill frontmatter fields, variable substitution, dynamic context injection, bundled resources, CLAUDE.md advanced features (@import, directory walking, claudeMdExcludes, managed policy), rules system (path-scoped rules, recursive discovery, symlinks), and plugin system (installation scopes, output styles, plugin settings), load the companion reference: `SKILL-reference.md`
