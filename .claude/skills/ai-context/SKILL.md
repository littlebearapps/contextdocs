---
name: ai-context
description: Generates, updates, and maintains AI IDE context files (AGENTS.md, CLAUDE.md, .cursorrules, copilot-instructions.md, .windsurfrules, .clinerules, GEMINI.md). Updates stale or out-of-date context files, promotes stable MEMORY.md patterns into CLAUDE.md, bootstraps new projects, and audits existing files for drift. Applies the Signal Gate principle — only includes what agents cannot discover on their own.
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
| CLAUDE.md | Under 80 lines | 120 lines |
| AGENTS.md | Under 120 lines | 160 lines |
| Other context files | Under 60 lines | 100 lines |

## Supported Context Files

| File | AI Tool | Purpose |
|------|---------|---------|
| `AGENTS.md` | Codex CLI, Cursor, Gemini CLI, Claude Code, OpenCode, Copilot, RooCode | Cross-tool agent context (60K+ repos) |
| `CLAUDE.md` | Claude Code, OpenCode | Project-specific instructions loaded every session |
| `.cursorrules` | Cursor | Editor-specific code generation rules |
| `.github/copilot-instructions.md` | GitHub Copilot | Repository-level Copilot instructions |
| `.windsurfrules` | Windsurf | Project rules for Cascade AI |
| `.clinerules` | Cline | Project context for autonomous tasks |
| `GEMINI.md` | Gemini CLI | Session context for Gemini CLI |

**CLAUDE.md vs MEMORY.md:** CLAUDE.md contains instructions *for* Claude (shared via git). MEMORY.md contains notes *by* Claude (local only). Promote recurring MEMORY.md insights to CLAUDE.md.

## Generation Workflow

1. **Detect project profile** — scan manifests for language, framework, test runner, linter, CI/CD
2. **Extract non-discoverable conventions** — import order, naming patterns, commands, security rules, environment quirks
3. **Generate context files** — apply Signal Gate filter. Each file uses the structure below.

### Context File Structure

**AGENTS.md** (~120 lines): Identity (1-2 lines), Conventions (non-default only), Commands (test/build/deploy/lint), Rules (hard constraints). Omit Project Structure, Architecture, Important Files.

**CLAUDE.md** (~80 lines): Project name + one sentence, Commands, Conventions (3-5 non-default bullets), Rules. Omit architecture, paths, directory listings.

**Other files** (~60 lines each): `.cursorrules`, `.windsurfrules`, `.clinerules`, `GEMINI.md`, `copilot-instructions.md` share the same core: description, conventions, commands, rules. Cline adds a `## Before Committing` checklist.

## Modes

### `init` — Bootstrap new project

Scan codebase, generate missing context files (skip existing), offer Context Guard hooks (Claude Code only), run audit pass, report summary.

### `update` — Incremental drift patching

Compare context file commits vs source commits. Classify changes (scripts → Commands, configs → Conventions, renames → paths). Apply surgical edits using Edit — preserve human customisations.

### `audit` — Staleness check

Check version accuracy, command accuracy, stale paths, new untracked conventions, MEMORY.md drift, Context Guard health.

### `promote` — MEMORY.md → CLAUDE.md

Find convention-like patterns in MEMORY.md ("Always", "Never", "Use", "Prefer"). Cross-reference against CLAUDE.md. Present candidates. Append promoted insights using Edit.

## AGENTS.md Spec

Tracks [agents.md spec](https://github.com/agentsmd/agents.md) v1.0 via `upstream-versions.json`. The `check-upstream` GitHub Action flags version drift. Do not implement draft v1.1 features until stable.

## Anti-Patterns

- Don't include discoverable content — directory trees, deps, architecture
- Don't ship auto-generated files unedited — always curate
- Don't repeat framework docs — agents know React, Express, Django
- Don't include secrets or session-specific state

## Claude Code Reference

For advanced agent/skill frontmatter fields, variable substitution, dynamic context injection, bundled resource patterns, CLAUDE.md advanced features (@import, directory walking, claudeMdExcludes, managed policy), rules system (path-scoped rules, recursive discovery, user-level rules, symlinks), and plugin system (installation scopes, .lsp.json, output styles, plugin settings), load the companion reference: `SKILL-reference.md`
