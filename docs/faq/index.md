---
title: "ContextDocs — Frequently Asked Questions"
description: "Common questions about ContextDocs: installation, supported AI tools, Signal Gate filtering, Context Guard hooks, headless mode, and how it relates to PitchDocs."
---

# Frequently Asked Questions

> Quick answers to the questions users ask most often. Once the marketing-site
> sync ships, this article is also available at
> `littlebearapps.com/help/contextdocs/faq/`.

## What is ContextDocs and why should I use it?

ContextDocs is a Claude Code plugin that generates and maintains AI context files for your project — `AGENTS.md`, `CLAUDE.md`, `.cursorrules`, `.github/copilot-instructions.md`, `.windsurfrules`, `.clinerules`, and `GEMINI.md` — from a single codebase scan. It applies the **Signal Gate principle** so the files only contain what AI agents cannot already discover by reading source code on their own.

The motivation is concrete: research from ETH Zurich (2026) shows that bloated context files reduce AI task success by roughly 3% and increase token costs by around 20%. Most teams either write too much, write the wrong things, or let context files go stale within a week. ContextDocs covers the full lifecycle — generation, drift patching, MEMORY.md promotion, freshness hooks, and 0–100 health scoring — so the files stay lean and accurate as your project evolves.

## How do I install ContextDocs?

You need [Claude Code](https://code.claude.com/) or [OpenCode](https://opencode.ai/) installed. From a Claude Code session, run:

```bash
# 1. Add the LBA plugin marketplace (once per machine)
/plugin marketplace add littlebearapps/lba-plugins

# 2. Install ContextDocs
/plugin install contextdocs@lba-plugins

# 3. Bootstrap AI context for your current project
/contextdocs:ai-context init
```

That generates `AGENTS.md` plus the bridge files for the seven other supported tools. Optionally, install Context Guard hooks to catch drift over time:

```bash
/contextdocs:context-guard install              # Tier 1 (Nudge) — reminds at session end
/contextdocs:context-guard install --tier enforce  # Tier 2 (Enforce) — also blocks commits
```

The full walkthrough lives in [Getting Started](../guides/getting-started.md).

## Which AI coding tools does ContextDocs support?

Eight, in tiers based on how much of the plugin's automation each tool can run. ContextDocs is installed natively in Claude Code or OpenCode; the generated Markdown files then work with every tool listed.

| Tier | Tools | What you get |
|------|-------|--------------|
| Full | Claude Code | Skills, hooks, agents, rules, autonomous maintenance |
| Tier 1 | Gemini CLI, Cursor, GitHub Copilot | Skills, hooks, agents (near-parity, evolving) |
| Tier 2 | Codex CLI, OpenCode, Cline | Skills, agents, manual verification |
| Tier 3 | Windsurf | Skills, rules, no automated hooks |

For Codex CLI, Gemini CLI, and OpenCode, `AGENTS.md` is auto-loaded natively. Cursor, Copilot, Windsurf, and Cline each load their own bridge file — those are generated from the same scan, so you don't have to copy anything by hand. The detailed Platform Support Matrix lives in [Troubleshooting → Cross-Tool Compatibility](../guides/troubleshooting.md#cross-tool-compatibility).

## What is the Signal Gate principle and why does it matter?

Signal Gate is the single rule ContextDocs applies when deciding what belongs in a context file: **only include what AI agents cannot discover by reading source code on their own.** That excludes directory listings, file trees, dependency lists, and architecture overviews that an agent finds itself in seconds — and includes the conventions, hidden constraints, security rules, and gotchas that an agent has no way to infer.

The reason it matters is the ETH Zurich finding: overstuffed context reduces task success by about 3% and raises token costs by about 20%. Signal Gate is what lets ContextDocs hit its line budgets (`AGENTS.md` <120 lines, `CLAUDE.md` <80, other bridges <60) without losing the signal that actually helps your AI tool make good calls.

## How do I keep my context files up to date?

Four lifecycle commands cover almost every drift case:

```bash
/contextdocs:ai-context update    # Patch only what drifted (incremental)
/contextdocs:ai-context promote   # Move stable MEMORY.md patterns into CLAUDE.md
/contextdocs:ai-context audit     # Check for staleness without changing anything
/contextdocs:context-verify       # Score health 0–100 across 6 dimensions
```

`update` is the workhorse — it reads existing files and patches only the sections that drifted, so manual customisations are preserved. `promote` graduates patterns that Claude Code has learned across sessions in `MEMORY.md` into your durable `CLAUDE.md`. `audit` is read-only and answers "what's stale right now?". For the autonomous version of this loop, install Context Guard hooks (next question).

## What are Context Guard hooks and when should I install them?

Context Guard hooks keep context files in sync as your project evolves, without you having to remember to run `update`. They are **Claude Code only** today — other tools don't yet expose the hook events the guards depend on. Two tiers are available:

- **SessionStart** validates context files at session start and warns if they are stale or over budget.
- **Tier 1 (Nudge)** reminds you at session end if context files may be stale.
- **Tier 2 (Enforce)** also blocks commits when structural files (skills, commands, agents, rules, manifests) haven't been reflected in `AGENTS.md` or the affected bridge files.

When a hook fires, the autonomous **context-updater** agent applies surgical edits — shared changes go to `AGENTS.md` first, then only the affected bridge sections are refreshed. Install with `/contextdocs:context-guard install` (idempotent), check with `/contextdocs:context-guard status`, and remove with `/contextdocs:context-guard uninstall`.

## Why don't ContextDocs skills auto-trigger in `claude -p` headless mode?

This is a known Claude Code platform issue ([anthropics/claude-code#32184](https://github.com/anthropics/claude-code/issues/32184)) affecting project-local plugins, not a ContextDocs bug. When you invoke `claude -p "prompt"` in non-interactive mode, project-local skills don't reliably auto-activate from natural-language triggers.

Normal usage is unaffected: interactive Claude Code terminal sessions, IDE extensions (VS Code, JetBrains), Untether and other remote-control bridges that use the interactive stdin JSON-RPC protocol, Context Guard hooks, generated context files, and rules all work as expected. Only shell scripts and CI pipelines that call `claude -p` and expect skill auto-activation are affected. Workaround: install ContextDocs globally rather than project-locally, or invoke commands explicitly via their `/contextdocs:` slash form rather than relying on NL triggering.

## Can I use ContextDocs alongside PitchDocs?

Yes. They are designed to work independently and complement each other. ContextDocs was extracted from [PitchDocs](https://github.com/littlebearapps/pitchdocs) v1.19.3 to follow the microtool philosophy — each plugin does one thing well.

- **PitchDocs** generates public-facing repository documentation: README, CHANGELOG, ROADMAP, user guides, launch artifacts.
- **ContextDocs** generates and maintains AI IDE context files: `AGENTS.md`, `CLAUDE.md`, and the bridges for Cursor, Copilot, Windsurf, Cline, and Gemini CLI.

There is no conflict — install whichever you need, or both. They write to different paths and run different commands.

## How do I check if my context files are healthy?

Run `/contextdocs:context-verify` from a Claude Code session, or `bin/context-verify.sh` as a standalone shell script if the plugin isn't installed. Both score your context files **0–100** across six dimensions with thirteen checks:

- **Line budget** — are files within their size targets?
- **Signal quality** — does the content pass Signal Gate (no discoverable content)?
- **Path accuracy** — do referenced file paths actually exist?
- **Consistency** — do bridge files stay aligned with `AGENTS.md`?
- **Freshness** — have files been updated since the last significant code change?
- **Context load** — is the aggregate token usage across all context files within healthy limits per tool?

The score lands in standard grade bands (A 90–100, B 80–89, C 70–79, D 60–69, F <60). Wire it into CI with `--min-score` so drift never reaches your team.

---

**See also:** [Getting Started](../guides/getting-started.md) · [Troubleshooting](../guides/troubleshooting.md) · [Support](../../SUPPORT.md) · [Open an issue](https://github.com/littlebearapps/contextdocs/issues/new)
