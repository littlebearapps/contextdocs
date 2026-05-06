---
title: "Troubleshooting & FAQ"
description: "Common ContextDocs issues and solutions — Signal Gate, Context Guard hooks, content filter errors, and cross-tool limitations."
type: how-to
difficulty: intermediate
last_verified: "1.5.0" # x-release-please-version
related:
  - guides/getting-started.md
order: 2
---

# Troubleshooting & FAQ

> **Summary**: Common issues when using ContextDocs and how to resolve them.

---

## Content Filter Errors (HTTP 400)

Claude Code's API content filter blocks output when generating certain standard open-source files. This is a known upstream issue, not a ContextDocs bug.

**High-risk files** (will almost always trigger): `CODE_OF_CONDUCT.md`, `LICENSE`, `SECURITY.md`

**Solution:** Fetch from canonical URLs:

```bash
# Contributor Covenant v3.0
curl -sL "https://www.contributor-covenant.org/version/3/0/code_of_conduct/code_of_conduct.md" -o CODE_OF_CONDUCT.md

# MIT License
curl -sL "https://raw.githubusercontent.com/spdx/license-list-data/main/text/MIT.txt" -o LICENSE
```

ContextDocs includes a content filter guard hook that warns before Write operations on high-risk files.

---

## Context Files Are Too Long

If generated context files exceed their line budgets, the Signal Gate filter may not be working correctly.

**Check:** Run `/contextdocs:context-verify` — it flags files over budget and identifies discoverable content that should be removed.

**Common causes:**
- Directory listings or file trees (agents find these on their own)
- Architecture overviews that describe what's visible in the code
- Repeated information across multiple context files

**Fix:** Run `/contextdocs:ai-context update` to regenerate with stricter Signal Gate filtering.

---

## Context Guard Hooks Not Triggering

1. Check status: `/contextdocs:context-guard status`
2. Verify entries exist in `.claude/settings.json`
3. Context Guard hooks are **Claude Code only** — they don't work in OpenCode, Cursor, or other tools
4. SessionStart fires at session start (validates context files, warns if stale); Tier 1 (nudge) triggers at session end; Tier 2 (guard) triggers at commit time

**If hooks were installed but aren't in settings.json:** Run `/contextdocs:context-guard install` again — it's idempotent.

---

## Context Files Out of Sync

If context files reference stale paths or outdated conventions:

```bash
# Check what drifted
/contextdocs:ai-context audit

# Patch only what changed
/contextdocs:ai-context update
```

The `update` command is incremental — it reads existing files and patches only the sections that drifted, preserving manual customisations.

---

## MEMORY.md Patterns Not Promoted

The `promote` command moves confirmed patterns from MEMORY.md into CLAUDE.md:

```bash
/contextdocs:ai-context promote
```

**Requirements:**
- MEMORY.md must exist (Claude Code creates this automatically)
- Patterns should be stable (confirmed across multiple interactions)
- CLAUDE.md must not already contain the same information

---

## Cross-Tool Compatibility

The AI coding tool landscape has converged around shared primitives. Most tools now support AGENTS.md, skills (SKILL.md), and hooks — not just static context files.

### Platform Support Matrix (March 2026)

| Feature | Claude Code | Gemini CLI | Copilot | Cursor | Codex CLI | OpenCode | Cline | Windsurf |
|---------|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| AGENTS.md auto-load | via @import | configurable | yes | yes | native | native | fallback | yes |
| Skills (SKILL.md) | yes | yes | yes | yes | yes | yes | merged | yes |
| Hooks | 12 events | 11 events | 8 (preview) | 4+ events | 2 (exp) | partial | 3 events | enterprise |
| Custom agents | yes | yes (exp) | yes | yes | yes | yes | read-only | limited |
| Rules directory | yes | via ext | yes | yes | no | partial | yes | yes |
| Plugin/extension model | plugin.json | extension | .github/ | marketplace | skills pkg | config | MCP | MCP |

### What ContextDocs Delivers Per Platform

| Tier | Platforms | Experience |
|------|----------|------------|
| **Full** | Claude Code | Skills + hooks + agents + rules + autonomous maintenance |
| **Tier 1** | Gemini CLI, Cursor, Copilot | Skills + hooks + agents (near-parity, coming soon) |
| **Tier 2** | Codex CLI, OpenCode, Cline | Skills + agents, manual verification |
| **Tier 3** | Windsurf | Skills + rules, no automated hooks |
| **Tier 4** | Aider | Context files only (`--read AGENTS.md`) |

### Getting Started by Platform

**Claude Code / OpenCode**: Install as a plugin — `/install github:littlebearapps/contextdocs`

**Codex CLI / Gemini CLI**: AGENTS.md is auto-loaded natively. Skills work if placed in the standard skills directory.

**Cursor / Copilot / Windsurf / Cline**: Run `/contextdocs:ai-context init` in Claude Code to generate all bridge files, or manually create the relevant context file (`.cursorrules`, `.github/copilot-instructions.md`, `.windsurfrules`, `.clinerules`).

**All platforms**: Run `bin/context-verify.sh` for 0-100 health scoring — no plugin system required.

See `docs/references/platform-capabilities.md` for detailed per-tool capability documentation.

---

## Headless Mode (`claude -p`) Limitations

ContextDocs skills may not auto-trigger when invoked via `claude -p` (headless/non-interactive mode). This is a [known Claude Code platform issue](https://github.com/anthropics/claude-code/issues/32184) affecting project-local plugins — not a ContextDocs bug.

**Unaffected (all normal usage):**
- Interactive Claude Code terminal sessions
- IDE extensions (VS Code, JetBrains) — use interactive protocol
- Untether / remote control bridges — use interactive stdin JSON RPC, not `-p`
- Context Guard hooks, rules, and agents — plain shell scripts, no skill triggering needed
- Generated context files — plain Markdown, tool-independent

**Affected (automation/scripting only):**
- Shell scripts calling `claude -p "prompt"` expecting skill auto-activation
- CI pipelines invoking skills via `claude -p`
- Automated eval testing of skill trigger rates

**Workaround:** If you need headless mode (e.g., CI pipelines), install ContextDocs globally rather than project-locally, or use explicit slash commands rather than relying on NL skill triggering.

---

## FAQ

### Where did this come from?

ContextDocs was extracted from [PitchDocs](https://github.com/littlebearapps/pitchdocs) v1.19.3 to follow the microtool philosophy — each tool does one thing well. PitchDocs handles public-facing documentation; ContextDocs handles AI IDE context files.

### Can I use both PitchDocs and ContextDocs?

Yes. They work independently and complement each other. PitchDocs generates README, CHANGELOG, and user guides. ContextDocs generates CLAUDE.md, AGENTS.md, and other AI context files.

### What is the Signal Gate principle?

Only include in context files what AI agents cannot discover by reading source code on their own. This keeps files lean and effective. Research shows overstuffed context files reduce AI task success by ~3% and increase token costs by 20%.

---

**Need help?** See [SUPPORT.md](../../SUPPORT.md) or [open an issue](https://github.com/littlebearapps/contextdocs/issues/new).
