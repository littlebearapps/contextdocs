---
title: "Platform Capabilities Reference"
description: "Detailed capability matrix for AI coding tools — what each platform supports and how ContextDocs integrates."
type: reference
last_verified: "1.5.0" # x-release-please-version
---

# Platform Capabilities Reference

> **Last researched:** March 2026. The AI coding tool landscape evolves rapidly — verify against each tool's latest release notes.

---

## Capability Matrix

| Capability | Claude Code | Gemini CLI | Copilot | Cursor | Codex CLI | OpenCode | Cline | Windsurf | Aider |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **Context files** |
| AGENTS.md auto-load | via @import | configurable | yes | yes | native | native | fallback | yes | no |
| Context file | CLAUDE.md | GEMINI.md | copilot-instructions.md | .cursor/rules/ | AGENTS.md | AGENTS.md | .clinerules/ | .windsurf/rules/ | CONVENTIONS.md |
| @import syntax | yes | yes | no | no | no | no | no | no | no |
| **Extensibility** |
| Skills (SKILL.md) | yes | yes | yes | yes | yes | yes | merged w/cmds | yes | no |
| Custom agents | yes | yes (exp) | yes | yes (v2.4) | yes | yes | read-only | limited | no |
| Rules directory | .claude/rules/ | via extensions | .github/instructions/ | .cursor/rules/ | no | partial | .clinerules/ | .windsurf/rules/ | no |
| Plugin/extension model | plugin.json | gemini-extension.json | .github/ plugins | marketplace | skills pkg | config | MCP self-install | MCP marketplace | no |
| MCP servers | yes | yes | yes | yes | yes | yes | yes | yes | no |
| Slash commands | yes | yes | via .prompt.md | via skills | yes (25+) | yes | merged w/skills | via workflows | yes (15+) |
| **Hooks** |
| Session start | yes | yes | yes (preview) | no | yes (exp) | no | no | no | no |
| Pre-tool use | yes | yes (BeforeTool) | yes (preview) | yes | no | no | yes | enterprise | no |
| Post-tool use | yes | yes (AfterTool) | yes (preview) | yes | no | no | yes | enterprise | no |
| Session end / Stop | yes | yes | yes (preview) | yes | yes (exp) | no | no | no | no |
| User prompt submit | yes | no | yes (preview) | yes | no | no | yes | no | no |
| Total hook events | 12 | 11 | 8 | 4+ | 2 | partial | 3 | enterprise | 0 |

---

## Per-Tool Details

### Claude Code

**Context loading:** Auto-loads `CLAUDE.md` from project root and ancestor directories. Does NOT auto-load `AGENTS.md` — use `@AGENTS.md` import in CLAUDE.md. Rules in `.claude/rules/*.md` are auto-loaded.

**Extension model:** Full plugin system via `.claude-plugin/plugin.json`. Supports skills, agents, hooks, rules, commands, MCP servers. Installed globally or per-project.

**Hooks:** 12 event types — PreToolUse, PostToolUse, Stop, SessionStart, SessionEnd, UserPromptSubmit, SubagentStop, PreCompact, Notification, and more. Four handler types: command (bash), http (webhook), prompt (single-turn LLM), agent (agentic verifier).

**ContextDocs support:** Full — all skills, hooks, agents, rules, and commands.

### Gemini CLI

**Context loading:** Auto-loads `GEMINI.md` from workspace and parent directories. Configurable via `settings.json` to load `AGENTS.md` as fallback (`context.fileName: ["AGENTS.md", "GEMINI.md"]`). Supports `@file.md` import syntax.

**Extension model:** Full extension framework via `gemini-extension.json`. Extensions bundle MCP servers, context files, slash commands, skills, agents, hooks, and policy rules. Installable from npm or local directories.

**Hooks:** 11 events — SessionStart, SessionEnd, BeforeAgent, AfterAgent, BeforeModel, AfterModel, BeforeToolSelection, BeforeTool, AfterTool, PreCompress, Notification. JSON stdin/stdout communication. Exit code 2 blocks execution.

**Agents:** Experimental (requires `experimental.enableAgents: true`). Local and remote subagents. Agent definitions as `.md` files in `agents/` directory.

**ContextDocs support:** Tier 1 — skills, hooks, agents, and policies all portable. Extension package planned.

### GitHub Copilot

**Context loading:** Auto-loads `.github/copilot-instructions.md` (repo-wide) and `.github/instructions/*.instructions.md` (path-scoped with `applyTo` glob). Also loads `AGENTS.md` from anywhere in the tree (nearest takes precedence). Custom agents in `.github/agents/*.agent.md`.

**Extension model:** Plugins with 5 primitives — agents, skills, hooks, MCP servers, and instructions. Marketplace available. `/plugin install owner/repo` syntax.

**Hooks:** 8 events (Preview) — sessionStart, sessionEnd, userPromptSubmitted, preToolUse, postToolUse, agentStop, subagentStop, errorOccurred. Configured in `.github/hooks/*.json`. preToolUse can approve or deny.

**Skills:** Open Agent Skills standard in `.github/skills/<name>/SKILL.md` or `.claude/skills/`. Cross-tool compatible (VS Code, CLI, coding agent).

**ContextDocs support:** Tier 1 — skills, hooks, agents, and instructions all portable. Package planned.

### Cursor

**Context loading:** `.cursor/rules/*.mdc` (modern, replacing deprecated `.cursorrules`). Also loads `AGENTS.md` with directory-scoped overrides. Four activation modes: Always Apply, Apply Intelligently, Apply to Specific Files (globs), Apply Manually.

**Extension model:** Plugin marketplace (since v2.4, Feb 2026). Plugins package skills, subagents, MCP servers, hooks, and rules. `/plugin install owner/repo` syntax.

**Hooks:** 4+ events — stop, beforeSubmitPrompt, PreToolUse, PostToolUse.

**Agents:** Subagents since v2.4. Custom subagents with own context, prompts, tool access, and models. Can load resources from `~/.claude/{skills,agents}`.

**ContextDocs support:** Tier 1 — skills, hooks, agents, and rules all portable. Plugin planned.

### Codex CLI

**Context loading:** `AGENTS.md` auto-loaded natively — walked from git root to CWD (hierarchical). Also checks `~/.codex/AGENTS.md` (global). Max combined size 32 KiB default.

**Extension model:** Open Agent Skills standard. Skills scanned from `.agents/skills` at CWD, repo root, `$HOME`, `/etc/codex/`, and bundled. Activated via `/skills`, `$skillname` mention, or auto-selected by description.

**Hooks:** Experimental — only SessionStart and Stop events. No PreToolUse/PostToolUse yet.

**Agents:** Yes. Subagents spawn on explicit request. Each runs independently with own model and tool access. Configured in `[agents]` section of `config.toml`.

**ContextDocs support:** Tier 2 — skills and agents work, hooks limited to session events.

### OpenCode

**Context loading:** `AGENTS.md` from project root (primary). `CLAUDE.md` as fallback (Claude Code compatibility). `~/.config/opencode/AGENTS.md` (global). Additional files via `instructions` field in `opencode.json`.

**Extension model:** Custom agents in `opencode.json` or `.opencode/agents/*.md`. Claude Code skill directory compatibility (`.claude/skills/`). Can be disabled via `OPENCODE_DISABLE_CLAUDE_CODE=1`.

**Hooks:** Partial. Does not natively run Claude Code JSON hooks. Open issue for compatibility.

**Agents:** Four built-in (Build, Plan, General, Explore) + custom agents. Per-agent tool permissions, model overrides, step limits.

**ContextDocs support:** Tier 2 — skills and agents work, no automated hooks.

### Cline

**Context loading:** `.clinerules` file or `.clinerules/` directory at project root. Auto-detects fallbacks: `.cursorrules`, `.windsurfrules`, `AGENTS.md`. Supports path-based conditional activation via `paths:` YAML frontmatter.

**Extension model:** MCP self-install. Hooks in `.clinerules/hooks/` (project) or `~/Documents/Cline/Rules/Hooks/` (global).

**Hooks:** 3 events — PreToolUse, PostToolUse, UserPromptSubmit. JSON stdin/stdout. macOS and Linux only (no Windows).

**Agents:** Subagents (disabled by default). Read-only — can explore but cannot write or run destructive commands.

**ContextDocs support:** Tier 2 — skills (merged with commands), hooks (3 events), read-only agents.

### Windsurf

**Context loading:** `.windsurf/rules/*.md` (workspace, 12,000 chars per file). `.windsurfrules` at root (legacy). `AGENTS.md` at root and subdirectories. Four activation modes: always_on, model_decision, glob, manual.

**Extension model:** MCP Marketplace for one-click installs. Skills in `.windsurf/skills/<name>/SKILL.md`. Workflows invoked via slash commands.

**Hooks:** Enterprise only — hooks on prompts for logging/policy, hooks on responses for auditing. Not developer-extensible.

**Agents:** Limited. Cascade is the primary agent. Fast Context subagent for code search. No custom subagent system.

**ContextDocs support:** Tier 3 — skills and rules work, no hooks or agents for non-enterprise.

### Aider

**Context loading:** No auto-loaded context file. Uses `CONVENTIONS.md` loaded via `--read` flag or `.aider.conf.yml` config. No native AGENTS.md support (feature requested).

**Extension model:** None. Slash commands only (15+ built-in). No skills, hooks, or agents. No MCP (PR pending).

**ContextDocs support:** Tier 4 — AGENTS.md loadable via `--read AGENTS.md`. Use `bin/context-verify.sh` for health scoring.

---

## ContextDocs Feature Portability

| ContextDocs Feature | Portable? | Notes |
|---|---|---|
| Signal Gate principle | Yes | Tool-agnostic methodology |
| AGENTS-first architecture | Yes | AGENTS.md widely supported |
| Line budgets | Yes | Measurable standards, any tool |
| ai-context skill | Yes | SKILL.md is cross-tool standard |
| context-verify skill | Yes | Checks are tool-agnostic |
| context-verify CLI | Yes | Bash script, no plugin needed |
| context-guard hooks | Partial | Need per-tool hook adapters |
| context-updater agent | Partial | Agent format differs per tool |
| Rules (auto-loaded) | Partial | Directory varies per tool |
| Plugin manifest | No | Claude Code specific |
| settings.json hooks | No | Claude Code specific |
| @AGENTS.md import | Partial | Claude Code + Gemini CLI only |

---

## Sources

| Tool | Documentation | Last Verified |
|---|---|---|
| Claude Code | [code.claude.com/docs](https://code.claude.com/docs) | March 2026 |
| Gemini CLI | [geminicli.com/docs](https://geminicli.com/docs) | March 2026 |
| GitHub Copilot | [docs.github.com/copilot](https://docs.github.com/copilot) | March 2026 |
| Cursor | [cursor.com/docs](https://cursor.com/docs) | March 2026 |
| Codex CLI | [developers.openai.com/codex](https://developers.openai.com/codex) | March 2026 |
| OpenCode | [opencode.ai/docs](https://opencode.ai/docs) | March 2026 |
| Cline | [docs.cline.bot](https://docs.cline.bot) | March 2026 |
| Windsurf | [docs.windsurf.com](https://docs.windsurf.com) | March 2026 |
| Aider | [aider.chat/docs](https://aider.chat/docs) | March 2026 |
