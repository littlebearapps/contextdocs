---
name: ai-context
description: Generates, updates, and maintains AGENTS-first AI IDE context files with AGENTS.md as canonical shared context and thin tool-specific bridges. Works across Claude Code, Codex CLI, Gemini CLI, OpenCode, Cursor, Copilot, Windsurf, and Cline. Use this skill when the user wants to create context files, generate AGENTS.md, set up CLAUDE.md or bridge files for a project, update or fix out-of-date context files, bootstrap context for a new repo, promote MEMORY.md patterns, audit context for drift, or generate cursorrules, copilot instructions, clinerules, windsurfrules, or GEMINI.md. This is the right skill for updating, regenerating, or fixing context files — not just checking them. Use proactively whenever context files may need attention, even if not explicitly requested.
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
| `AGENTS.md` | Canonical shared context | Shared identity, commands, conventions, constraints, security notes, and monorepo guidance |
| `CLAUDE.md` | Thin bridge | Claude-specific rules, key files, and workflow notes (use `@AGENTS.md` import in Claude Code) |
| `.cursorrules` | Thin bridge | Cursor-specific rule scoping or metadata only |
| `.github/copilot-instructions.md` | Thin bridge | Copilot-specific review and PR guidance only |
| `.windsurfrules` | Thin bridge | Windsurf-specific rule activation or metadata only |
| `.clinerules` | Thin bridge | Cline-specific autonomy boundaries and commit checklist |
| `GEMINI.md` | Thin bridge | Gemini-specific discovery or extension notes only |

**Context file vs memory:** Context files contain instructions *for* the agent (shared via git). Memory files (MEMORY.md, agent-memory/) are notes *by* the agent (local only). Promote recurring memory insights to the appropriate context file.

## Generation Workflow

1. **Detect project profile** — scan manifests for language, framework, test runner, linter, CI/CD
2. **Extract non-discoverable conventions** — import order, naming patterns, commands, security rules, environment quirks
3. **Generate `AGENTS.md` first** — put all shared commands, conventions, rules, and security notes in one canonical file
4. **Generate bridge files** — apply the Signal Gate again so each tool-specific file stays thin and only adds tool-unique behaviour

### Context File Structure

**AGENTS.md** (~120 lines): Identity, commands, non-default conventions, hard constraints, security notes, monorepo guidance. Omit Project Structure, architecture, dependency dumps, and key file tables.

**CLAUDE.md** (~10-20 lines, hard max 80): In Claude Code, use `@AGENTS.md` to import the canonical context, then add only Claude-specific additions (`.claude/rules/` references, key file pointers, path-scoped guidance). In other tools, CLAUDE.md is not used — AGENTS.md is loaded directly.

**Other bridge files** (~10-20 lines each, hard max 60): reference or subset `AGENTS.md`, then add only tool-specific fields. Cline may add a `## Before Committing` checklist. `.windsurfrules` and `GEMINI.md` are compatibility bridges for now — keep them especially lean.

## Modes

### `init` — Bootstrap new project

Scan codebase, generate `AGENTS.md` plus all bridge files that don't already exist (CLAUDE.md, .cursorrules, copilot-instructions.md, .windsurfrules, .clinerules, GEMINI.md). Skip files that already exist. Offer Context Guard hooks (Claude Code only), run audit pass, report summary. Users can delete bridge files for tools they don't use after generation.

### `update` — Incremental drift patching

Compare context file commits vs source commits. Classify changes (scripts → Commands, configs → Conventions, renames → paths). Update `AGENTS.md` first, then only the bridge files whose tool-specific sections or references changed. Apply surgical edits using Edit — preserve human customisations.

### `audit` — Staleness check

Check version accuracy, command accuracy, stale paths, bridge contradictions against `AGENTS.md`, new untracked conventions, MEMORY.md drift, Context Guard health.

### `promote` — MEMORY.md → CLAUDE.md

Find convention-like patterns in MEMORY.md ("Always", "Never", "Use", "Prefer"). Cross-reference against CLAUDE.md. Present candidates. Append promoted insights using Edit.

## AGENTS.md Spec

Tracks [agents.md spec](https://github.com/agentsmd/agents.md) v1.0 via `upstream-versions.json`. The `check-upstream` GitHub Action flags version drift. Do not implement draft v1.1 features until stable.

## Anti-Patterns

- Don't include discoverable content — directory trees, deps, architecture
- Don't ship auto-generated files unedited — always curate
- Don't repeat framework docs — agents know React, Express, Django
- Don't include secrets or session-specific state

## Platform Notes

**AGENTS.md auto-load:** Codex CLI, OpenCode, Cursor, Windsurf, Cline, and Copilot load AGENTS.md natively. Claude Code requires `@AGENTS.md` in CLAUDE.md. Gemini CLI is configurable via `context.fileName` in settings.json.

**Hooks:** Context Guard hooks are available on Claude Code (12 events), Gemini CLI (11), Copilot (8, preview), Cursor (4+), Cline (3), and Codex CLI (2, experimental). See the context-guard skill for per-platform setup.

**Standalone verification:** Run `bin/context-verify.sh` on any platform for 0-100 health scoring without a plugin system.

## Advanced Reference (Claude Code)

For agent/skill frontmatter fields, variable substitution, dynamic context injection, bundled resources, CLAUDE.md advanced features (@import, directory walking, claudeMdExcludes, managed policy), rules system (path-scoped rules, recursive discovery, symlinks), and plugin system (installation scopes, output styles, plugin settings), load the companion reference: `SKILL-reference.md`
