# ContextDocs Plugin Test Results

**Date**: 2026-03-11
**Plugin version**: 1.1.0

## Phase 1: Deterministic Tests

### Hook Unit Tests

| Hook | Tests | Pass | Fail |
|------|-------|------|------|
| content-filter-guard | 25 | 25 | 0 |
| context-structural-change | 14 | 14 | 0 |
| context-commit-guard | 12 | 12 | 0 |
| context-drift-check | 6 | 6 | 0 |
| context-guard-stop | 8 | 8 | 0 |
| **Total** | **65** | **65** | **0** |

### Other Checks

| Check | Result |
|-------|--------|
| Token budgets | PASS |
| Banned phrases | CLEAN |
| Frontmatter validation | PASS |
| llms.txt validation | PASS |

## Phase 2: Activation Evals

**Run**: `run-20260311-130208.json`
**Model**: haiku
**Overall**: 6/20 (30%) — below 80% target

### By Category

| Category | Pass | Total | Rate |
|----------|------|-------|------|
| Positive (slash commands) | 0 | 11 | 0% |
| Positive (natural language) | 3 | 4 | 75% |
| Negative | 3 | 5 | 60% |
| **Overall** | **6** | **20** | **30%** |

### Failures

| Test ID | Input | Expected | Got | Root Cause |
|---------|-------|----------|-----|------------|
| cmd-ai-context-* (5) | `/contextdocs:ai-context *` | ai-context | none | Slash cmds not activated in headless mode |
| cmd-context-guard-* (3) | `/contextdocs:context-guard *` | context-guard | none | Same |
| cmd-context-verify* (2) | `/contextdocs:context-verify *` | context-verify | none | Same |
| nl-stale-context | "My CLAUDE.md is out of date..." | ai-context | none | Weak ai-context NL triggers |
| nl-memory-promote | "Move my MEMORY.md patterns..." | ai-context | none | Weak ai-context NL triggers |
| negative-readme | "Generate a README..." | none | pitchdocs:readme | False positive — PitchDocs correct |
| negative-changelog | "/pitchdocs:changelog" | none | pitchdocs:changelog | False positive — PitchDocs correct |

### Issues Filed

- Slash command activation in headless mode (9 failures)
- ai-context skill weak NL activation (2 failures)
- Eval runner false positives from cross-plugin activations (2 failures)

## Phase 3: CI Integration

- `docs-ci.yml` updated with hook tests + banned phrases steps
- `activation-evals.yml` created (manual dispatch)
- `ANTHROPIC_API_KEY` secret configured
