---
name: context-verify
description: Validates AI context file quality — signal-to-noise ratio, line budgets, stale paths, cross-file consistency, discoverable content detection, and MEMORY.md drift. Scores context health and integrates with CI. Use to catch context file decay before it reaches your repo.
---

# Context Verifier

## Philosophy

Generating context files is solved — `ai-context` handles that. Preventing decay is not. This skill validates that AI context files remain accurate, lean, and consistent. Overstuffed context files reduce AI task success by ~3% (ETH Zurich, 2026).

## Verification Checks

### 1. Line Budget Compliance

Check line counts and estimate tokens (lines × 4). Apply budgets:

| File | Warning | Over Budget |
|------|---------|-------------|
| CLAUDE.md | >80 lines | >120 lines |
| AGENTS.md | >120 lines | >160 lines |
| Other context files | >60 lines | >100 lines |

### 2. Discoverable Content Detection

Flag file tree characters (├──, └──, │), "Project Structure" sections with directory listings, dependency lists mirroring manifests, and architecture descriptions visible from source code. Report specific line numbers.

### 3. Stale Path Detection

Extract backtick-quoted paths from context files and verify each exists on disk. Report stale paths.

### 4. Cross-File Consistency

Key commands (test, build, deploy) must match across all context files. Extract and compare command strings. Flag mismatches.

### 5. MEMORY.md Drift

If a project MEMORY.md exists, check for convention-like patterns ("Always", "Never", "Use") not yet promoted to CLAUDE.md.

### 6. Context Guard Status

Check for hook scripts in `.claude/hooks/context-*.sh` and entries in `.claude/settings.json`.

### 8. @import Path Validation

If any CLAUDE.md contains `@path/to/file` import lines, verify each target exists on disk. Report broken imports with the source file and line number.

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

## Scoring

| Dimension | Max | Deductions |
|-----------|-----|-----------|
| Line Budget | 20 | -2 per file over warning, -5 per file over budget |
| Signal Quality | 20 | -1 per discoverable instance (max -5), -3 if "Project Structure" present |
| Path Accuracy | 20 | -2 per stale path or broken @import (max -10) |
| Consistency | 15 | -3 if test/build/deploy commands differ between files |
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

## CI Integration

With `ci` argument, output machine-readable format and exit code 1 on failures. Accept `--min-score N` to fail the CI job below a threshold.
