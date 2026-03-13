---
name: contextdocs
description: AGENTS-first AI IDE context management — generate, maintain, and audit canonical AGENTS.md plus thin bridge files for CLAUDE.md, .github/copilot-instructions.md, .cursorrules, .windsurfrules, .clinerules, and GEMINI.md using the Signal Gate principle. Includes Context Guard hooks and context health scoring. Zero runtime dependencies.
version: "1.3.0"
author: Little Bear Apps
tags:
  - ai-context
  - agents-md
  - claude-md
  - context-guard
  - signal-gate
  - claude-code-plugin
---

# ContextDocs — AI Context File Management

## Overview

ContextDocs is a pure Markdown Claude Code plugin that generates, maintains, and audits AGENTS-first AI IDE context files for 8 tools. `AGENTS.md` carries the shared project conventions, and every generated bridge file follows the Signal Gate principle — only what agents cannot discover on their own — keeping context lean and effective.

3 skills, 3 slash commands, 2 quality rules, 6 opt-in hooks, 13 verification checks. 100% Markdown, zero runtime dependencies, MIT licensed.

## When to Use

- Starting a new project and need canonical `AGENTS.md` plus bridge files for multiple tools
- Existing context files have drifted out of date with your codebase
- CLAUDE.md or other bridge files are bloated with content that belongs in `AGENTS.md`
- You want to promote patterns from MEMORY.md into CLAUDE.md
- Need to score context file quality for CI/CD enforcement

## Instructions

1. Install the plugin:
   ```
   /plugin marketplace add littlebearapps/lba-plugins
   /plugin install contextdocs@lba-plugins
   ```

2. Navigate to any project repository

3. Run commands:
   - `/contextdocs:ai-context init` — Bootstrap canonical `AGENTS.md` plus all needed bridges
   - `/contextdocs:ai-context update` — Patch only what drifted
   - `/contextdocs:ai-context promote` — Move MEMORY.md patterns to CLAUDE.md
   - `/contextdocs:ai-context audit` — Check for staleness and drift
   - `/contextdocs:context-guard install` — Install freshness hooks (Claude Code only)
   - `/contextdocs:context-verify` — Score context file health (0–100)

## Output Format

Each generated file is written directly to the repository. `AGENTS.md` is the shared source of truth; bridge files add only tool-specific guidance.

| File | Role | Budget |
|------|------|--------|
| AGENTS.md | Canonical shared context | <120 lines |
| CLAUDE.md | Claude bridge | <80 lines |
| .cursorrules | Cursor bridge | <60 lines |
| .github/copilot-instructions.md | Copilot bridge | <60 lines |
| .windsurfrules | Windsurf compatibility bridge | <60 lines |
| .clinerules | Cline bridge | <60 lines |
| GEMINI.md | Gemini compatibility bridge | <60 lines |

## Notes

- Works with Claude Code and OpenCode natively; generated files support 8 AI tools total
- Signal Gate filtering excludes directory listings, file trees, and architecture overviews
- Context Guard hooks are Claude Code only (opt-in)
- For public-facing documentation (README, CHANGELOG, ROADMAP), see [PitchDocs](https://github.com/littlebearapps/pitchdocs)
