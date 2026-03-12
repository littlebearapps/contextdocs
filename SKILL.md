---
name: contextdocs
description: AI IDE context file management — generate, maintain, and audit AGENTS.md, CLAUDE.md, .cursorrules, copilot-instructions.md, .windsurfrules, .clinerules, and GEMINI.md using the Signal Gate principle. Includes Context Guard hooks and context health scoring. Zero runtime dependencies.
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

ContextDocs is a pure Markdown Claude Code plugin that generates, maintains, and audits AI IDE context files for 7 tools. Every generated file follows the Signal Gate principle — only what agents cannot discover on their own — keeping context lean and effective.

3 skills, 3 slash commands, 2 quality rules, 6 opt-in hooks, 13 verification checks. 100% Markdown, zero runtime dependencies, MIT licensed.

## When to Use

- Starting a new project and need AI context files for multiple tools
- Existing context files have drifted out of date with your codebase
- CLAUDE.md or AGENTS.md is overstuffed with discoverable content
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
   - `/contextdocs:ai-context init` — Bootstrap all 7 context file types
   - `/contextdocs:ai-context update` — Patch only what drifted
   - `/contextdocs:ai-context promote` — Move MEMORY.md patterns to CLAUDE.md
   - `/contextdocs:ai-context audit` — Check for staleness and drift
   - `/contextdocs:context-guard install` — Install freshness hooks (Claude Code only)
   - `/contextdocs:context-verify` — Score context file health (0–100)

## Output Format

Each command produces Markdown files written directly to the repository. Context files follow strict line budgets:

| File | Budget | Tool |
|------|--------|------|
| CLAUDE.md | <80 lines | Claude Code |
| AGENTS.md | <120 lines | Codex CLI, OpenCode, Gemini CLI |
| .cursorrules | <60 lines | Cursor |
| copilot-instructions.md | <60 lines | GitHub Copilot |
| .windsurfrules | <60 lines | Windsurf |
| .clinerules | <60 lines | Cline |
| GEMINI.md | <60 lines | Gemini CLI |

## Notes

- Works with Claude Code and OpenCode natively; generated files work with 7 AI tools total
- Signal Gate filtering excludes directory listings, file trees, and architecture overviews
- Context Guard hooks are Claude Code only (opt-in)
- For public-facing documentation (README, CHANGELOG, ROADMAP), see [PitchDocs](https://github.com/littlebearapps/pitchdocs)
