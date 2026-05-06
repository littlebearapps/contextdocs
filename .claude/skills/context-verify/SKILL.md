---
name: context-verify
description: Validates AI context file quality with 16 checks and 0-100 health scoring. Works on any platform — also available as a standalone CLI script (bin/context-verify.sh). Validates line budgets, AGENTS-to-bridge consistency, stale paths, MEMORY.md drift, plugin manifest, and modern Cursor (.cursor/rules/*.mdc) / Cline (.clinerules/) / Copilot (AGENTS.md native) layouts.
when_to_use: |
  Trigger phrases:
  - "check context file health" or "validate my context files"
  - "score context for CI" or "run context-verify"
  - "are my CLAUDE.md / AGENTS.md / .cursorrules consistent?"
  - "find stale paths in context files"
  - "check if .cursorrules is using the legacy format" (suggests modern .cursor/rules/*.mdc)
  - "audit context quality before release"
  - "is MEMORY.md drifting from CLAUDE.md?"
  - "check aggregate context token load"
  - "verify @AGENTS.md import in CLAUDE.md"
  Skip when:
  - The user wants to generate or regenerate context files (use ai-context)
  - The user wants to install hooks (use context-guard)
  - They are mid-debug on an unrelated error
  - The repository has no AI context files yet (run ai-context init first)
---

# Context Verifier

## Philosophy

Generating context files is solved — `ai-context` handles that. Preventing decay is not. This skill validates that AI context files remain accurate, lean, and consistent. Overstuffed context files reduce AI task success by ~3% (ETH Zurich, 2026).

## Verification Checks

### 1. Line Budget Compliance

Check line counts and estimate tokens (lines × 4). Apply budgets:

| File | Warning | Over Budget |
|------|---------|-------------|
| AGENTS.md | >120 lines | >160 lines |
| CLAUDE.md bridge | >20 lines | >80 lines |
| Other bridge files | >20 lines | >60 lines |

Warn on bridge length only when the extra lines appear to restate shared `AGENTS.md` content rather than genuine tool-specific instructions.

### 2. Discoverable Content Detection

Flag file tree characters (├──, └──, │), "Project Structure" sections with directory listings, dependency lists mirroring manifests, and architecture descriptions visible from source code. Report specific line numbers.

### 3. Stale Path Detection

Extract backtick-quoted paths from context files and verify each exists on disk. Report stale paths.

### 4. AGENTS-to-Bridge Consistency

Treat `AGENTS.md` as the canonical shared context. Bridge files may subset or reference it, but they must not contradict key commands, hard rules, naming conventions, or security notes. Flag missing bridge references (for example `@AGENTS.md` in `CLAUDE.md`) and bridges that duplicate AGENTS sections instead of staying thin.

### 5. MEMORY.md Drift

If a project MEMORY.md exists, check for convention-like patterns ("Always", "Never", "Use") not yet promoted to CLAUDE.md.

### 6. Context Guard Status *(Claude Code, Gemini CLI, Copilot, Cursor)*

Check for hook scripts and registration entries. In Claude Code: `.claude/hooks/context-*.sh` and `.claude/settings.json`. Other platforms use their own hook directories.

### 7. Context Load (Aggregate Token Estimate)

Calculate per-tool aggregate token load using the tool-to-file mapping from `.claude/rules/context-quality.md`. Thresholds: <5,000 tokens healthy, 5,000–10,000 warning, >10,000 over budget.

Report format shows per-tool totals with file-level breakdown and top contributors:

```
Context Load:
  Claude Code: ~3,200 tokens (~1.6% of 200K window) ✓
    CLAUDE.md — 320 tokens
    AGENTS.md — 480 tokens
    .claude/rules/*.md — 2,400 tokens ← top contributor
```

### 8. @import Path Validation

If any CLAUDE.md contains `@path/to/file` import lines, verify each target exists on disk. Report broken imports with the source file and line number.

### 9. Rule Path-Scope Validation

If any `.claude/rules/*.md` has `paths:` YAML frontmatter, verify each glob pattern matches at least one existing file. Report orphaned path-scope rules where globs match nothing.

### 10. Rule Symlink Targets

If any `.claude/rules/*.md` is a symlink, verify the target file exists. Report broken symlinks with the rule name and dangling target path.

### 11. .mcp.json Validation

If `.mcp.json` exists, validate JSON structure — check `mcpServers` object exists, each server has a valid `command` or `url` field, and referenced commands exist on PATH or as relative paths. Report structural errors and invalid server entries.

### 12. Agent Memory Directory Hygiene

Check if `.claude/agent-memory/` or `.claude/agent-memory-local/` directories are tracked in git (they should be gitignored — these contain per-agent runtime state). Warn if tracked. Check for `.gitignore` entries covering these paths.

### 13. Plugin Manifest Completeness

If `.claude-plugin/plugin.json` exists, verify required fields: `name`, `version`, `description`. Warn on missing optional fields: `keywords`, `author`, `repository`. Report missing fields.

### 14. Modern Cursor Layout Check

If `.cursorrules` exists but `.cursor/rules/` does not, warn that current Cursor versions ignore the legacy single-file format in Agent mode. Suggest migrating to `.cursor/rules/agents.mdc` with `description`, `globs`, and `alwaysApply` frontmatter. If both exist, note that the legacy file is redundant. If only `.cursor/rules/` exists, mark as healthy.

### 15. Modern Cline Layout Check

If `.clinerules` is a flat file (not a directory), suggest migrating to `.clinerules/` directory mode with optional `paths:` frontmatter for path-scoped rules. If `.clinerules/` directory exists, validate that each Markdown file has either no frontmatter or valid `paths:` frontmatter pointing to existing files.

### 16. Copilot Bridge Optionality *(advisory only)*

If `.github/copilot-instructions.md` exists and `AGENTS.md` is present, count unique non-trivial lines in the Copilot bridge that aren't in AGENTS.md. If fewer than 5, suggest deletion (Copilot loads AGENTS.md natively since Aug 2025). Advisory only — never deducts.

## Scoring

| Dimension | Max | Deductions |
|-----------|-----|-----------|
| Line Budget | 20 | -2 per file over warning, -5 per file over budget |
| Signal Quality | 20 | -1 per discoverable instance (max -5), -3 if "Project Structure" present, -3 if agent memory dirs tracked in git |
| Path Accuracy | 20 | -2 per stale path, broken @import, orphaned path-scope rule, broken rule symlink, or invalid .mcp.json server entry (max -10) |
| Consistency | 15 | -3 if a bridge contradicts AGENTS.md on commands or rules, -2 if a required bridge reference/import is missing, -2 per missing required plugin manifest field |
| Freshness | 15 | -2 if MEMORY.md not promoted, -3 per file stale 90+ days |
| Context Load | 10 | -3 per tool over 5K warning, -5 per tool over 10K budget |

### Grade Bands

| Score | Grade | Label |
|-------|-------|-------|
| 90–100 | A | Lean and current |
| 80–89 | B | Minor tuning needed |
| 70–79 | C | Needs attention |
| 60–69 | D | Significant drift |
| <60 | F | Overhaul recommended |

Report includes per-dimension breakdown and specific actions to reach grade A.

The new layout checks (14, 15) deduct 2 points each for using legacy formats; check 16 is advisory and never deducts.

## Standalone CLI

For platforms without skill support, or for CI pipelines, use the standalone script:

```bash
bin/context-verify.sh              # Interactive report
bin/context-verify.sh --ci         # CI mode (exit 1 below threshold)
bin/context-verify.sh --ci --min-score 90  # Custom threshold
```

The CLI implements checks 1, 3, 5–16 automatically (bash + git). Check 2 (discoverable content) and check 4 (bridge consistency) are partially automated — full semantic analysis requires this AI-powered skill.

## CI Integration

With `ci` argument (skill or CLI), output machine-readable format and exit code 1 on failures. Accept `--min-score N` to fail the CI job below a threshold.
