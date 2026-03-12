# Context Guard — Hook System Reference

Companion reference for the context-guard skill. Loaded on demand when configuring, debugging, or extending Claude Code hooks.

## Hook Event Types

Claude Code supports 17 hook event types. Each receives JSON on stdin and expects JSON on stdout.

### Session Lifecycle

| Event | Fires When | Can Block | Can Modify Input |
|-------|-----------|-----------|-----------------|
| `SessionStart` | Session begins or resumes | No | No (can inject `additionalContext`) |
| `SessionEnd` | Session terminates | No | No |

### Tool Lifecycle

| Event | Fires When | Can Block | Can Modify Input |
|-------|-----------|-----------|-----------------|
| `PreToolUse` | Before a tool executes | Yes (`deny`, `escalate`) | Yes (`toolInputOverride`) |
| `PostToolUse` | After a tool succeeds | Yes | No |
| `PostToolUseFailure` | After a tool fails | Yes | No |

### User Interaction

| Event | Fires When | Can Block | Can Modify Input |
|-------|-----------|-----------|-----------------|
| `UserPromptSubmit` | User submits a prompt | Yes (`block`) | No |
| `PermissionRequest` | Permission dialog appears | Yes (`allow`, `deny`, `escalate`) | No |
| `Stop` | Claude finishes responding | Yes (`block`) | No |

### Agent Lifecycle

| Event | Fires When | Can Block | Can Modify Input |
|-------|-----------|-----------|-----------------|
| `SubagentStart` | Subagent spawns | No | No |
| `SubagentStop` | Subagent finishes | Yes | No |

### Task and Notification

| Event | Fires When | Can Block | Can Modify Input |
|-------|-----------|-----------|-----------------|
| `TaskCompleted` | Task marked complete | Yes | No |
| `Notification` | Notification sent | No | No |
| `TeammateIdle` | Agent teammate going idle | Yes | No |

### Configuration

| Event | Fires When | Can Block | Can Modify Input |
|-------|-----------|-----------|-----------------|
| `ConfigChange` | Config file changes mid-session | Yes | No |
| `InstructionsLoaded` | CLAUDE.md or rules loaded into context | No | No (can inject `additionalContext`) |

### Workspace

| Event | Fires When | Can Block | Can Modify Input |
|-------|-----------|-----------|-----------------|
| `WorktreeCreate` | Worktree created (isolation mode) | No | No |
| `WorktreeRemove` | Worktree removed at session/subagent end | No | No |

### Context

| Event | Fires When | Can Block | Can Modify Input |
|-------|-----------|-----------|-----------------|
| `PreCompact` | Before context window compaction | No | No |

## Handler Types

Four handler types process hook events:

| Type | Execution | Input | Output | Use When |
|------|-----------|-------|--------|----------|
| `command` | Shell script | JSON on stdin | JSON on stdout + exit code | File checks, git operations, lightweight validation |
| `http` | HTTP POST | JSON request body | JSON response body | External webhooks, logging services, CI triggers |
| `prompt` | Single-turn LLM | Rendered prompt template | Yes/no decision | Content review, policy checking |
| `agent` | Subagent with tools | Agent prompt | Decision + reasoning | Complex verification needing Read, Grep, Glob |

### Command Handler Pattern

All ContextDocs hooks use the `command` handler type:

```bash
#!/bin/bash
set -euo pipefail
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)

# Gate logic — exit silently if not relevant
[ "$TOOL_NAME" != "Bash" ] && echo '{}' && exit 0

# Check logic here...

# Advisory output
cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "Your message here"
  }
}
EOF
```

**Exit codes:** 0 = allow/advisory, 1 = block Write, 2 = block commit.

## Advanced Features

### Input Modification (PreToolUse only)

PreToolUse hooks can modify tool parameters before execution:

```json
{
  "decision": "allow",
  "toolInputOverride": {
    "command": "npm test -- --coverage"
  }
}
```

### Environment Variables

Available to all hook handlers:

| Variable | Value |
|----------|-------|
| `CLAUDE_SESSION_ID` | Current session identifier |
| `CLAUDE_PROJECT_DIR` | Project root directory |
| `CLAUDE_TRANSCRIPT_PATH` | Path to session transcript (JSONL) |
| `CLAUDE_ENV_FILE` | File for persisting env vars across hook invocations |
| `CLAUDE_PLUGIN_ROOT` | Plugin root (for plugin-scoped hooks) |

### CLAUDE_ENV_FILE

Write `KEY=VALUE` lines to `$CLAUDE_ENV_FILE` to persist environment variables across hook invocations within a session. Variables are available to subsequent hooks and tool executions.

### Async Execution

```json
{
  "hooks": [{
    "type": "command",
    "command": ".claude/hooks/slow-check.sh",
    "async": true
  }]
}
```

Async hooks run in the background. They cannot block or modify tool input.

### Once Flag

```json
{
  "hooks": [{
    "type": "command",
    "command": ".claude/hooks/session-setup.sh",
    "once": true
  }]
}
```

The hook fires only once per session. Supported in skills and agents; not supported in project-local plugins.

### Timeout

Default timeout is 10 minutes. Override per-hook:

```json
{
  "hooks": [{
    "type": "command",
    "command": ".claude/hooks/quick-check.sh",
    "timeout": 5000
  }]
}
```

Value in milliseconds.

### Matcher Patterns

Filter which tools or events trigger a hook using regex:

```json
{
  "matcher": "Write|Edit",
  "hooks": [{ "type": "command", "command": ".claude/hooks/guard.sh" }]
}
```

Matchers apply to tool names for PreToolUse/PostToolUse events. Omit `matcher` for events without tool context (SessionStart, Stop, etc.).

## settings.json Structure

Hook configuration lives in `.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write",
        "hooks": [{ "type": "command", "command": ".claude/hooks/content-filter-guard.sh" }]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [{ "type": "command", "command": ".claude/hooks/context-drift-check.sh" }]
      }
    ],
    "SessionStart": [
      {
        "hooks": [{ "type": "command", "command": ".claude/hooks/context-session-start.sh" }]
      }
    ],
    "Stop": [
      {
        "hooks": [{ "type": "command", "command": ".claude/hooks/context-guard-stop.sh" }]
      }
    ]
  }
}
```

### Hook Snapshots

Hooks are captured at session startup. Changes to `.claude/settings.json` during a session take effect on the next session. Use `/hooks` to review the active hook configuration.

## Stability Notes

Claude Code ships 4–7 releases per week with no stability policy. Hook event names, JSON schemas, and handler behaviour can change without notice. ContextDocs tracks upstream changes via `check-upstream.yml` — if an `upstream-drift` issue is open, review this reference for accuracy.
