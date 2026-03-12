# AI Context — Claude Code Reference

Companion reference for the ai-context skill. Loaded on demand when generating or auditing Claude Code-specific context files (agents, skills, rules, hooks, plugins).

## Agent Frontmatter Fields

All fields for `.claude/agents/*.md` YAML frontmatter:

| Field | Type | Default | When to Use |
|-------|------|---------|-------------|
| `name` | string | *required* | Unique identifier (lowercase + hyphens) |
| `description` | string | recommended | When Claude should delegate to this agent — used for auto-invocation |
| `tools` | list | all tools | Allowlist of tools the agent can use. Use `Agent(worker)` to restrict subagent spawning |
| `disallowedTools` | list | none | Denylist — simpler than listing every allowed tool when blocking a few |
| `model` | string | inherit | `sonnet`, `opus`, `haiku`, or `inherit` from parent |
| `permissionMode` | string | default | `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, `plan` |
| `maxTurns` | number | unlimited | Cap agentic turns to prevent runaway — 8–15 typical for focused tasks |
| `memory` | string | none | Persistent cross-session memory: `user`, `project`, or `local` scope |
| `isolation` | string | none | `worktree` for temporary git worktree — safe parallel work |
| `background` | boolean | false | `true` to always run as background task |
| `skills` | list | none | Skills preloaded into agent context (full content injected at startup) |
| `mcpServers` | list | none | MCP servers available to this agent only |
| `hooks` | object | none | Lifecycle hooks scoped to this agent |

### Agent Memory Directories

When `memory` is set, agents persist state across sessions:

- `user` scope: `~/.claude/agent-memory/<name>/`
- `project` scope: `.claude/agent-memory/<name>/` (committed to git)
- `local` scope: `.claude/agent-memory-local/<name>/` (gitignored)

Each directory contains a `MEMORY.md` index (first 200 lines loaded at startup) plus topic files loaded on demand.

## Skill Frontmatter Fields

All fields for `.claude/skills/<name>/SKILL.md` YAML frontmatter:

| Field | Type | Default | When to Use |
|-------|------|---------|-------------|
| `name` | string | dir name | Display name; becomes the `/name` slash command |
| `description` | string | recommended | When to use — Claude uses this for auto-invocation |
| `argument-hint` | string | none | Autocomplete hint (e.g., `[issue-number]`) |
| `disable-model-invocation` | boolean | false | `true` = manual `/command` only, Claude cannot auto-trigger |
| `user-invocable` | boolean | true | `false` = hidden from `/` menu (internal-only skills) |
| `allowed-tools` | list | none | Tools allowed without permission prompts when skill is active |
| `model` | string | inherit | Model override while skill is active |
| `context` | string | none | `fork` to run in an isolated subagent |
| `agent` | string | none | Agent type for `context: fork` (e.g., `Explore`, custom agent name) |
| `hooks` | object | none | Lifecycle hooks scoped to this skill (`once: true` fires only once) |

## Variable Substitution

Available in skill body text and hook commands:

| Variable | Expands To |
|----------|-----------|
| `$ARGUMENTS` | Full argument string after the command name |
| `$ARGUMENTS[0]`, `$ARGUMENTS[1]` | Positional arguments (0-indexed) |
| `$1`, `$2`, `$N` | Shorthand for `$ARGUMENTS[0]`, `$ARGUMENTS[1]`, etc. |
| `${CLAUDE_SESSION_ID}` | Current session identifier |
| `${CLAUDE_SKILL_DIR}` | Absolute path to the skill's directory |
| `${CLAUDE_PLUGIN_ROOT}` | Absolute path to the plugin root |

## Dynamic Context Injection

Skills can run shell commands at load time using backtick-bang syntax:

```markdown
Current git branch: !`git branch --show-current`
Project version: !`node -p "require('./package.json').version"`
```

The command output replaces the placeholder before the skill content is sent to Claude.

## Bundled Resources

Skill directories can contain subdirectories loaded on demand:

```
skills/<name>/
  SKILL.md              # Main skill (always loaded)
  SKILL-reference.md    # Companion reference (loaded when needed)
  scripts/              # Shell scripts referenced by skill
  references/           # Reference docs loaded on demand
  assets/               # Images, templates, static files
```

Companion files (`SKILL-*.md`) are loaded when the skill explicitly references them. They have a higher token budget (~3000 tokens / 12,000 chars) than the main SKILL.md (~2000 tokens / 8,000 chars).

## CLAUDE.md Advanced Features

### @import Syntax

CLAUDE.md files can import other Markdown files using `@path/to/file.md`. Paths resolve relative to the importing file. Maximum chain depth: 5 hops. First-time external imports show an approval dialog.

```markdown
# Project Context
@.claude/conventions.md
@docs/api-rules.md
```

Use @import when a CLAUDE.md approaches the 80-line budget — split conventions, commands, and rules into separate files and import them.

### Directory Walking

Claude Code walks up from the current working directory, loading every `CLAUDE.md` found in ancestor directories. Subdirectory `CLAUDE.md` files load on demand when Claude reads files in those directories. This creates a natural hierarchy:

```
repo/
  CLAUDE.md              # Root context (always loaded)
  frontend/
    CLAUDE.md            # Loaded when working in frontend/
  backend/
    CLAUDE.md            # Loaded when working in backend/
```

When generating context for monorepos, recommend subdirectory `CLAUDE.md` files over a single large root file.

### claudeMdExcludes Setting

In `.claude/settings.json`, the `claudeMdExcludes` array takes glob patterns to skip specific `CLAUDE.md` files. Useful in monorepos where irrelevant packages would bloat context:

```json
{
  "claudeMdExcludes": ["packages/deprecated-*/CLAUDE.md", "vendor/**/CLAUDE.md"]
}
```

Cannot exclude managed policy files.

### Managed Policy CLAUDE.md

Organisations can deploy a managed `CLAUDE.md` at system level:
- Linux/WSL: `/etc/claude-code/CLAUDE.md`
- macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`

Managed policy files load before all other CLAUDE.md files, cannot be excluded, and cannot be overridden by project settings. When auditing context load, account for managed policy if present.

## Rules System

### Path-Scoped Rules

Rules can restrict which files they apply to using `paths:` YAML frontmatter with glob patterns:

```yaml
---
paths:
  - "src/frontend/**/*.tsx"
  - "src/frontend/**/*.ts"
---
# Frontend Conventions
Use React Server Components by default...
```

Claude Code only loads the rule when working on files matching the globs. Use path-scoped rules instead of subdirectory `CLAUDE.md` files when conventions apply to specific file patterns rather than directory trees.

### Recursive Discovery

Claude Code discovers rules recursively under `.claude/rules/`. Subdirectories organise rules by domain:

```
.claude/rules/
  context-quality.md       # Always loaded (no paths: restriction)
  frontend/
    react-patterns.md      # paths: ["src/frontend/**"]
    styling.md             # paths: ["**/*.css", "**/*.scss"]
  backend/
    api-conventions.md     # paths: ["src/api/**"]
```

### User-Level Rules

`~/.claude/rules/*.md` files load before project rules and apply to all projects. Use for personal conventions (editor preferences, commit style) that should not be committed to a shared repo.

### Symlink Support

Rules can be symlinks pointing to shared files in other directories or repos. Claude Code resolves symlinks to their targets. When generating context-verify checks, verify symlink targets exist on disk.
