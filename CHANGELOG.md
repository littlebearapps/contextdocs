# Changelog

All notable changes to ContextDocs will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

* **context-updater agent** — autonomous agent that updates stale AI context files after structural project changes, launched by hooks without user intervention (Claude Code only)
* **autonomous actions rule** — context-awareness rule now instructs Claude Code to launch the context-updater agent automatically on hook triggers, closing the detection-to-action loop
* **6 comprehensive CI checks** — spell check, actionlint, frontmatter validation, llms.txt consistency, orphan detection, and token budget verification ([bec24ab](https://github.com/littlebearapps/contextdocs/commit/bec24ab))
* **activation eval runner** — new test suite for plugin activation and trigger detection to validate skill triggering accuracy ([08aac68](https://github.com/littlebearapps/contextdocs/commit/08aac68))
* **hook unit tests** — comprehensive test coverage for all context-guard hooks with CI integration ([55c6906](https://github.com/littlebearapps/contextdocs/commit/55c6906))
* **banned phrases checker** — CI check to enforce consistent language and terminology across AI context files ([55c6906](https://github.com/littlebearapps/contextdocs/commit/55c6906))

### Changed

* **context-verify: aggregate context load check** — new 6th scoring dimension estimates per-tool token usage across all loaded context files, flags when combined static context exceeds 5K (warning) or 10K (over budget) tokens per tool
* hooks now reference the context-updater agent instead of suggesting manual slash commands — Stop hook, commit guard, structural change reminder, and drift check all direct Claude to launch the agent
* context-guard skill documents the new agent component and updated installation steps
* context-quality rule now includes per-tool load paths table and aggregate token thresholds
* **plugin optimisation** — trimmed skills and strengthened context files for Anthropic best practices ([b6ca593](https://github.com/littlebearapps/contextdocs/commit/b6ca593))
* **improved skill NL trigger descriptions** — stronger natural language patterns for ai-context skill activation ([bd2503f](https://github.com/littlebearapps/contextdocs/commit/bd2503f))
* **enhanced activation evaluation** — eval runner now specifically flags ContextDocs skill activations for more accurate trigger testing ([d96899d](https://github.com/littlebearapps/contextdocs/commit/d96899d))

### Fixed

* spell check command in CLAUDE.md and allow HTML center tag in typos config ([19af130](https://github.com/littlebearapps/contextdocs/commit/19af130))
* **robust stream-json parsing** — improved skill detection using multiple parsing strategies to handle edge cases in streaming JSON responses ([0da56cc](https://github.com/littlebearapps/contextdocs/commit/0da56cc))
* **unprefixed slash commands in activation evals** — activation evaluation now uses unprefixed commands to accurately test skill triggering in Claude Code context ([9028dcf](https://github.com/littlebearapps/contextdocs/commit/9028dcf))

### Known Issues

* **Headless mode skill activation** — skills may not auto-trigger via `claude -p` (non-interactive mode). This is a [Claude Code platform limitation](https://github.com/anthropics/claude-code/issues/32184) affecting project-local plugins, not a ContextDocs bug. Interactive mode works correctly.

### Documentation

* updated RESULTS.md with activation eval findings and upstream issue tracking ([71a6177](https://github.com/littlebearapps/contextdocs/commit/71a6177))

## [1.1.0](https://github.com/littlebearapps/contextdocs/compare/v1.0.0...v1.1.0) (2026-03-10)


### Added

* initial ContextDocs v1.0.0 — AI context file management plugin ([2aad25e](https://github.com/littlebearapps/contextdocs/commit/2aad25eacc3563e33b51c47c69d0fcc3513329db))


### Documentation

* add full documentation suite — guides, CONTRIBUTING, SECURITY, SUPPORT, SKILL.md ([04b41a8](https://github.com/littlebearapps/contextdocs/commit/04b41a8e0fb30e427587f6c1362b61ccba110044))
* add logo and hero image to README ([8405d4a](https://github.com/littlebearapps/contextdocs/commit/8405d4a83613d9d8bfc1056d2bd395eb053d8228))
* generate llms-full.txt for LLM content consumption ([c5e01b9](https://github.com/littlebearapps/contextdocs/commit/c5e01b98e0061ed1486b87369af4f48bd2780e89))
* upgrade README to PitchDocs standard, add CI workflows and GEO patterns ([c4287a7](https://github.com/littlebearapps/contextdocs/commit/c4287a72155affd40ee804802012ad83ce320a85))

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
