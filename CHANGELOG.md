# Changelog

All notable changes to ContextDocs will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.1/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0](https://github.com/littlebearapps/contextdocs/releases/tag/v1.0.0) (2026-03-10)

### Added

- **AI context file generation** — generate AGENTS.md, CLAUDE.md, .cursorrules, copilot-instructions.md, .windsurfrules, .clinerules, and GEMINI.md from codebase analysis using the Signal Gate principle (moved from PitchDocs v1.19.3)
- **Context Guard hooks** — two-tier enforcement for AI context file freshness: session-end nudge (Tier 1) and pre-commit blocking (Tier 2), plus post-commit drift detection, structural change reminders, and content filter protection (moved from PitchDocs v1.19.3)
- **Context verification scoring** — 0–100 health score across 5 dimensions (line budget, signal quality, path accuracy, consistency, freshness) with CI integration (new, extracted from PitchDocs docs-verify Check 11)
- **Lifecycle commands** — `init` (bootstrap), `update` (incremental drift patching), `promote` (MEMORY.md → CLAUDE.md), `audit` (staleness check)
- **Context awareness rule** — auto-loaded trigger map suggesting ContextDocs commands when context-relevant work is detected
- **AGENTS.md spec tracking** — pinned version in upstream-versions.json, monthly GitHub Action check for drift

### Migration from PitchDocs

If you previously used `/pitchdocs:ai-context` or `/pitchdocs:context-guard`, install ContextDocs and use the new prefixed commands:

- `/pitchdocs:ai-context` → `/contextdocs:ai-context`
- `/pitchdocs:context-guard` → `/contextdocs:context-guard`
- NEW: `/contextdocs:context-verify` (context health scoring)

Context Guard hooks already installed in projects continue to work — they are per-project files, not plugin-dependent.
