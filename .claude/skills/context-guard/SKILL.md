---
name: context-guard
description: Installs opt-in Claude Code hooks with two-tier enforcement for AI context file freshness. Use this skill when the user wants to install context hooks, set up commit guards for context files, prevent stale CLAUDE.md or AGENTS.md from being committed, detect context drift, add content filter guards for OSS files, check context guard status, or uninstall context hooks. Covers install, install strict, uninstall, and status. Claude Code only — hooks do not work in OpenCode, Codex CLI, or other tools.
---

# Context Guard

## What It Does

Hooks and a quality rule to keep AI context files in sync with the codebase. Prevents content filter errors on standard OSS files. Two-tier enforcement for context doc freshness.

**Claude Code only.** OpenCode, Codex CLI, Cursor, Windsurf, Cline, and Gemini CLI do not support Claude Code hooks. Cross-tool features (skills, AGENTS.md) work without Context Guard.

## Enforcement Tiers

| Tier | Name | Mechanism | Behaviour |
|------|------|-----------|-----------|
| 1 | Nudge | Stop hook | Advisory — suggests updating context docs before session ends |
| 2 | Guard | PreToolUse on `git commit` | Blocking — prevents commits when structural files staged without context updates (exit 2) |

Default: Tier 1 only. Add Tier 2 with `install strict`.

## Components

### content-filter-guard.sh (PreToolUse → Write)

- **HIGH-risk** (CODE_OF_CONDUCT.md, LICENSE, SECURITY.md): blocks write, returns fetch commands for canonical URL
- **MEDIUM-risk** (CHANGELOG.md, CONTRIBUTING.md): allows write, advises chunked writing
- **All other files:** passes through silently

### context-structural-change.sh (PostToolUse → Write|Edit)

Fires after creating/editing structural files. Reminds which context files may need updating:
- `commands/*.md`, `.claude/skills/*/SKILL.md`, `.agents/skills/*/SKILL.md` → update `AGENTS.md` first, then `CLAUDE.md`, `llms.txt`, and any affected bridge files
- `.claude/agents/*.md`, `.agents/agents/*.md` → `AGENTS.md`, `llms.txt`
- `.claude/rules/*.md` → `AGENTS.md` and `CLAUDE.md` if rule references changed
- Config files (`package.json`, `pyproject.toml`, etc.) → update `AGENTS.md` first, then only the bridge files with tool-specific command/tooling notes

If your repository uses the `.agents/` layout instead of `.claude/`, apply the same AGENTS-first update order to the equivalent skill and agent paths above.

### context-drift-check.sh (PostToolUse → Bash)

Fires after `git commit`. Compares context file last-modified commit vs most recent source commit. Detects broken path references. Throttled to max once per hour via `.git/.context-guard-last-check`.

### context-guard-stop.sh (Stop — Tier 1)

Fires on session end. Checks for uncommitted structural changes without context updates. Returns `{"decision": "block"}` if drift detected. Checks `stop_hook_active` flag to prevent infinite loops.

### context-commit-guard.sh (PreToolUse → Bash — Tier 2)

Fires before `git commit`. Checks staging area for structural files without context files. Exit 2 blocks the commit.

### context-session-start.sh (SessionStart)

Fires at session start. Quick context health check: counts context files, detects stale files (source commits ahead), warns if aggregate line count exceeds budget. Advisory only — cannot block session start.

### context-updater agent

Autonomous agent (`.claude/agents/context-updater.md`) launched by Claude in response to hook output. Applies surgical, incremental context file updates. Uses `.git/.context-updater-running` flag for loop prevention.

## Installation

`/contextdocs:context-guard install` (Tier 1): copies hooks to `.claude/hooks/`, agent to `.claude/agents/`, rule to `.claude/rules/`, merges config into `.claude/settings.json`.

`/contextdocs:context-guard install strict` (Tier 1 + 2): adds `context-commit-guard.sh` and its PreToolUse Bash entry.

### Settings.json

```json
{
  "hooks": {
    "PreToolUse": [
      { "matcher": "Write", "hooks": [{ "type": "command", "command": ".claude/hooks/content-filter-guard.sh" }] },
      { "matcher": "Bash", "hooks": [{ "type": "command", "command": ".claude/hooks/context-commit-guard.sh" }] }
    ],
    "PostToolUse": [
      { "matcher": "Bash", "hooks": [{ "type": "command", "command": ".claude/hooks/context-drift-check.sh" }] },
      { "matcher": "Write|Edit", "hooks": [{ "type": "command", "command": ".claude/hooks/context-structural-change.sh" }] }
    ],
    "SessionStart": [
      { "hooks": [{ "type": "command", "command": ".claude/hooks/context-session-start.sh" }] }
    ],
    "Stop": [
      { "hooks": [{ "type": "command", "command": ".claude/hooks/context-guard-stop.sh" }] }
    ]
  }
}
```

The PreToolUse Bash entry for `context-commit-guard.sh` is only added with `install strict` (Tier 2).

## Uninstallation

`/contextdocs:context-guard uninstall` removes all hook scripts, the context-updater agent, settings.json entries, and the quality rule.

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Hooks not firing | `chmod +x .claude/hooks/*.sh` |
| No output after commit | Delete `.git/.context-guard-last-check` to reset throttle |
| "jq: command not found" | Install jq: `apt install jq` or `brew install jq` |
| Claude loops on stop | Verify `context-guard-stop.sh` checks `stop_hook_active` flag; or remove Stop entry from settings.json |
| Tier 2 false positive | Stage a context file with a minor update, or remove the commit guard PreToolUse entry |

## Untether Compatibility

When running via [Untether](https://github.com/littlebearapps/untether) (Telegram bridge), `context-guard-stop.sh` checks `UNTETHER_SESSION` env var and exits immediately — Stop hook blocks would displace user content in Telegram output. All other hooks (drift check, structural reminders, content filter, commit guard) work normally. If you don't use Untether, this has no effect.

## Hook System Reference

For the complete hook event catalogue (17 events), handler types (command, http, prompt, agent), advanced features (async, once, timeout, matcher, updatedInput, CLAUDE_ENV_FILE), and settings.json schema, load the companion reference: `SKILL-reference.md`
