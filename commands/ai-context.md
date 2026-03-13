---
description: "Generate, update, or audit AI IDE context files with AGENTS.md as the canonical shared context and tool-specific bridge files. Signal Gate principle — only what agents cannot discover: $ARGUMENTS"
argument-hint: "[claude|agents|cursor|copilot|windsurf|cline|gemini|all|init|update|promote|audit] or no args for all"
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
  - Write
  - Edit
---

# /ai-context

Generate lean context files that help AI coding assistants understand your project's non-obvious conventions and constraints. ContextDocs now treats `AGENTS.md` as the canonical shared context, then emits tool-specific bridge files that reference or subset it plus add only tool-unique behaviour. Applies the Signal Gate principle — excludes discoverable content (directory listings, file trees, architecture overviews) that research shows reduces AI task success.

## Behaviour

1. Load the `ai-context` skill for templates, the Signal Gate, and the codebase analysis workflow
2. Load the `context-quality` rule for quality criteria
3. Run the codebase analysis: detect language, framework, test runner, linter, conventions
4. For `all`, `init`, and `update`, generate or refresh `AGENTS.md` as the canonical shared context
5. Generate the requested bridge file(s) from the same analysis, keeping them thin and limited to tool-specific additions. Single-tool modes (`claude`, `cursor`, `copilot`, `windsurf`, `cline`, `gemini`) update only the requested bridge; use `agents` when you want to refresh `AGENTS.md` itself.

## Arguments

### Generate
- **No arguments** / `all`: Generate `AGENTS.md` plus all applicable bridge files (`CLAUDE.md`, `.cursorrules`, `.github/copilot-instructions.md`, `.windsurfrules`, `.clinerules`, `GEMINI.md`)
- `claude`: Generate CLAUDE.md only
- `agents`: Generate AGENTS.md only
- `cursor`: Generate .cursorrules only
- `copilot`: Generate .github/copilot-instructions.md only
- `windsurf`: Generate .windsurfrules only
- `cline`: Generate .clinerules only
- `gemini`: Generate GEMINI.md only

Single-tool generate modes leave `AGENTS.md` unchanged so targeted bridge refreshes stay predictable.

### Lifecycle
- `init`: Bootstrap a new project — generate missing context files, offer Context Guard hooks, run audit. Skips existing files.
- `update`: Patch only what drifted since the last context update, using git change detection. Preserves human edits.
- `promote`: Scan Claude Code's auto-memory (MEMORY.md) for stable patterns and assist promoting them to CLAUDE.md.
- `audit`: Check existing context files for staleness, drift, discoverable content, and Context Guard status.

## Output

Each generated file is written directly to disk. `AGENTS.md` holds the shared commands, conventions, hard constraints, and security rules. Bridge files should stay minimal and include only tool-specific material. Line counts should stay within the Signal Gate budgets (`AGENTS.md` <120, `CLAUDE.md` <80, other bridge files <60).

```
AI Context Files:
  ✓ AGENTS.md — generated canonical context (74 lines)
  ✓ CLAUDE.md — generated bridge (`@AGENTS.md` + Claude-specific notes, 14 lines)
  ✓ .cursorrules — generated bridge (12 lines)
  ✓ .github/copilot-instructions.md — generated bridge (11 lines)
  ✓ .windsurfrules — generated compatibility bridge (10 lines)
  ✓ .clinerules — generated bridge (15 lines)
  ✓ GEMINI.md — generated compatibility bridge (9 lines)
```

Audit mode:
```
AI Context Audit:
  ✓ AGENTS.md — up to date (74 lines, canonical shared context)
  ⚠ CLAUDE.md — bridge missing `@AGENTS.md` import
  ✗ .cursorrules — contradicts AGENTS.md lint command (`npm run lint` vs `pnpm lint`)
  · GEMINI.md — not present (optional compatibility bridge)
  ℹ MEMORY.md — contains 3 conventions that may belong in CLAUDE.md (run /contextdocs:ai-context promote)

  Context Guard:
    ✓ Tier 1 active (Stop hook)
    ✗ Tier 2 not installed
```
