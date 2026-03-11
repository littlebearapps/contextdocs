---
title: "Getting Started with ContextDocs"
description: "Install ContextDocs, generate your first AI context files, and set up Context Guard hooks."
type: how-to
difficulty: beginner
time_to_complete: "5 minutes"
last_verified: "1.2.0"
related:
  - guides/troubleshooting.md
order: 1
---

# Getting Started with ContextDocs

> **Summary**: Install ContextDocs, generate AI context files for 7 tools, and optionally set up Context Guard hooks for freshness enforcement.

**Time to Hello World:** Under 60 seconds for your first context files. Full walkthrough below: ~5 minutes.

## Prerequisites

- [Claude Code](https://code.claude.com/) or [OpenCode](https://opencode.ai/) installed
- A project repository you want to add AI context files to

---

## 1. Install ContextDocs

Open Claude Code in your terminal and run:

```bash
# Add the LBA plugin marketplace (once per machine)
/plugin marketplace add littlebearapps/lba-plugins

# Install ContextDocs
/plugin install contextdocs@lba-plugins
```

**Note:** When installed as a plugin, all commands use the `contextdocs:` prefix (e.g., `/contextdocs:ai-context`).

---

## 2. Bootstrap Context Files

Navigate to the project you want to add context files to, then run:

```bash
/contextdocs:ai-context init
```

ContextDocs will:
1. Scan your codebase (manifest files, project structure, conventions)
2. Apply the Signal Gate filter — only include what agents cannot discover on their own
3. Generate up to 7 context files, each within its line budget:

| File | Tool | Budget |
|------|------|--------|
| CLAUDE.md | Claude Code | <80 lines |
| AGENTS.md | Codex CLI, OpenCode, Gemini CLI | <120 lines |
| .cursorrules | Cursor | <60 lines |
| .github/copilot-instructions.md | GitHub Copilot | <60 lines |
| .windsurfrules | Windsurf | <60 lines |
| .clinerules | Cline | <60 lines |
| GEMINI.md | Gemini CLI | <60 lines |

**Tip:** To generate a single file, specify the tool: `/contextdocs:ai-context claude` or `/contextdocs:ai-context cursor`.

---

## 3. Verify Context Quality

Check that your generated files are healthy:

```bash
/contextdocs:context-verify
```

This scores your context files 0–100 across 6 dimensions:
- **Line budget** — are files within their size targets?
- **Signal quality** — does the content pass Signal Gate (no discoverable content)?
- **Path accuracy** — do referenced file paths actually exist?
- **Consistency** — do files agree on conventions, tech stack, and key paths?
- **Freshness** — have files been updated since the last significant code change?
- **Context load** — is the aggregate token usage across all context files within healthy limits per tool?

---

## 4. Set Up Context Guard (Optional, Claude Code Only)

Context Guard hooks keep your context files in sync as your project evolves:

```bash
/contextdocs:context-guard install
```

This installs hooks with two tiers of enforcement:

- **Tier 1 (Nudge)** — at session end, reminds you if context files may be stale
- **Tier 2 (Guard)** — blocks commits when context files haven't been updated after structural changes

Hooks automatically launch the **context-updater agent** to apply updates — no manual intervention needed. The agent applies surgical edits to only the affected sections, respecting line budgets and the Signal Gate principle.

To check hook status or uninstall:

```bash
/contextdocs:context-guard status
/contextdocs:context-guard uninstall
```

---

## 5. Keep Context Fresh

As your project evolves, context files drift. Use these commands to maintain them:

```bash
# Patch only what drifted (incremental update)
/contextdocs:ai-context update

# Move patterns from MEMORY.md into CLAUDE.md
/contextdocs:ai-context promote

# Check for staleness without changing anything
/contextdocs:ai-context audit
```

---

## What's Next?

- **Generate public-facing docs** — Install [PitchDocs](https://github.com/littlebearapps/pitchdocs) for README, CHANGELOG, ROADMAP, user guides, and launch artifacts
- **Improve context quality** — Run `/contextdocs:context-verify` after changes to track your score over time
- **Explore the skills** — Each command loads specialised reference knowledge. See the [Available Skills](../../AGENTS.md#available-skills) table for details.

---

**Need help?** See [SUPPORT.md](../../SUPPORT.md) for getting help, common questions, and contact details.
