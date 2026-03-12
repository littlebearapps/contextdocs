---
description: "Install, uninstall, or check status of Context Guard hooks for AI context file freshness: $ARGUMENTS"
argument-hint: "[install|install strict|uninstall|status] — Claude Code only"
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
  - Write
  - Edit
---

# /context-guard

Install opt-in hooks that detect stale AI context files, remind you to update them, and prevent content filter errors when generating standard OSS files. **Claude Code only** — these hooks use Claude Code's PreToolUse, PostToolUse, and Stop hook system, which is not supported by OpenCode, Codex CLI, or other AI coding tools.

Context Guard has two enforcement tiers:

- **Tier 1 — Nudge** (default): Advisory. A Stop hook suggests updating context docs before the session ends. Claude can still stop if context docs genuinely don't need changes.
- **Tier 2 — Guard** (opt-in): Blocking. A PreToolUse hook blocks `git commit` when structural files are staged without context doc updates.

## Behaviour

1. Load the `context-guard` skill for reference
2. Execute the requested action: `install`, `install strict`, `uninstall`, or `status`

## Arguments

- **`install`**: Install Context Guard (Tier 1) into the current project:
  1. Create `.claude/hooks/` directory if it does not exist
  2. Copy `context-drift-check.sh`, `context-structural-change.sh`, `content-filter-guard.sh`, `context-guard-stop.sh`, and `context-session-start.sh` from the plugin's `hooks/` directory to `.claude/hooks/`
  3. Make the scripts executable (`chmod +x`)
  4. Create `.claude/agents/` directory if it does not exist
  5. Copy `context-updater.md` from the plugin's `.claude/agents/` directory to `.claude/agents/context-updater.md`
  6. Merge PreToolUse, PostToolUse, SessionStart, and Stop hook entries into `.claude/settings.json` (create the file if needed; if entries already exist, append without overwriting)
  7. Copy `context-quality.md` to `.claude/rules/context-quality.md` (create directory if needed)
  8. Report what was installed

- **`install strict`**: Install Context Guard (Tier 1 + Tier 2) into the current project:
  1. Perform all steps from `install` above
  2. Additionally copy `context-commit-guard.sh` from the plugin's `hooks/` directory to `.claude/hooks/`
  3. Add a PreToolUse Bash hook entry for `context-commit-guard.sh` to `.claude/settings.json`
  4. Report what was installed, noting Tier 2 is active

- **`uninstall`**: Remove all Context Guard hooks from the current project:
  1. Remove `.claude/hooks/context-drift-check.sh`, `.claude/hooks/context-structural-change.sh`, `.claude/hooks/content-filter-guard.sh`, `.claude/hooks/context-guard-stop.sh`, `.claude/hooks/context-session-start.sh`, and `.claude/hooks/context-commit-guard.sh`
  2. Remove all Context Guard hook entries (PreToolUse, PostToolUse, SessionStart, and Stop) from `.claude/settings.json` (preserve other hooks)
  3. Remove `.claude/rules/context-quality.md`
  4. Remove `.claude/agents/context-updater.md`
  5. Report what was removed

- **`status`**: Check installation state and current drift:
  1. Check if hook scripts exist in `.claude/hooks/`
  2. Check if hook entries are present in `.claude/settings.json`
  3. Check if the quality rule exists in `.claude/rules/`
  4. Check if the context-updater agent exists in `.claude/agents/`
  5. Determine which tier is active (Tier 1 if Stop hook present, Tier 2 if commit guard also present)
  6. Run a quick drift check (same logic as `/contextdocs:ai-context audit`) to report current staleness
  7. Report findings

## Output

### Install
```
Context Guard installed (Tier 1 — Nudge):
  ✓ .claude/hooks/context-drift-check.sh — warns after commits if context files are stale
  ✓ .claude/hooks/context-structural-change.sh — reminds after structural file changes
  ✓ .claude/hooks/content-filter-guard.sh — blocks Write on high-risk OSS files, advises on medium-risk
  ✓ .claude/hooks/context-guard-stop.sh — nudges to update context docs before session ends
  ✓ .claude/hooks/context-session-start.sh — quick context health check at session start
  ✓ .claude/agents/context-updater.md — autonomous agent for surgical context file updates
  ✓ .claude/rules/context-quality.md — auto-loaded quality standards for context files
  ✓ .claude/settings.json — PreToolUse, PostToolUse, SessionStart, and Stop hooks registered

Tier 2 (Guard) not installed. Run /contextdocs:context-guard install strict to also
block commits when structural files change without context doc updates.

Note: These hooks are Claude Code-specific. If your team also uses OpenCode or
Codex CLI, the hooks will be ignored by those tools (no errors, just no effect).
Add .claude/hooks/ to .gitignore if you prefer hooks to be per-developer.
```

### Install Strict
```
Context Guard installed (Tier 1 + Tier 2 — Nudge + Guard):
  ✓ .claude/hooks/context-drift-check.sh — warns after commits if context files are stale
  ✓ .claude/hooks/context-structural-change.sh — reminds after structural file changes
  ✓ .claude/hooks/content-filter-guard.sh — blocks Write on high-risk OSS files, advises on medium-risk
  ✓ .claude/hooks/context-guard-stop.sh — nudges to update context docs before session ends
  ✓ .claude/hooks/context-session-start.sh — quick context health check at session start
  ✓ .claude/hooks/context-commit-guard.sh — blocks commits with stale context docs
  ✓ .claude/agents/context-updater.md — autonomous agent for surgical context file updates
  ✓ .claude/rules/context-quality.md — auto-loaded quality standards for context files
  ✓ .claude/settings.json — PreToolUse, PostToolUse, SessionStart, and Stop hooks registered
```

### Status
```
Context Guard Status:
  ✓ Tier 1 — Nudge (Stop hook active — reminds about context docs before session end)
  ✓ Tier 2 — Guard (commit blocker active — blocks commits with stale context)
  ✓ Base hooks installed (3/3 scripts in .claude/hooks/)
  ✓ Settings configured (PreToolUse, PostToolUse, and Stop entries in .claude/settings.json)
  ✓ Context-updater agent installed (.claude/agents/context-updater.md)
  ✓ Quality rule active (.claude/rules/context-quality.md)

Drift check:
  ✓ CLAUDE.md — up to date
  ⚠ AGENTS.md — 12 source commits since last update
  ✓ .cursorrules — up to date
  · GEMINI.md — not present
```
