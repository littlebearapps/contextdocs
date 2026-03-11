---
title: "Troubleshooting & FAQ"
description: "Common ContextDocs issues and solutions — Signal Gate, Context Guard hooks, content filter errors, and cross-tool limitations."
type: how-to
difficulty: intermediate
last_verified: "1.1.0"
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
4. Tier 1 (nudge) triggers at session end; Tier 2 (guard) triggers at commit time

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

| Feature | Claude Code | OpenCode | Codex CLI | Cursor | Windsurf | Cline | Gemini CLI |
|---------|------------|----------|-----------|--------|----------|-------|------------|
| Plugin install | Yes | Yes | No | No | No | No | No |
| Context file generation | Yes | Yes | Manual | Manual | Manual | Manual | Manual |
| Context Guard hooks | Yes | No | No | No | No | No | No |
| Context verification | Yes | Yes | Manual | Manual | Manual | Manual | Manual |

For tools without plugin support, copy the relevant context file into your project manually. The generated files (.cursorrules, .windsurfrules, etc.) work with their respective tools automatically.

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
