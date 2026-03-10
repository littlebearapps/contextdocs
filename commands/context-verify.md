---
description: "Validate AI context file quality — signal-to-noise ratio, line budgets, stale paths, cross-file consistency, and context health scoring: $ARGUMENTS"
argument-hint: "[ci|ci --min-score N] or no args for interactive report"
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
---

# /context-verify

Validate the quality and freshness of AI context files in the current project. Scores signal-to-noise ratio, checks line budgets, detects stale paths, verifies cross-file consistency, and flags MEMORY.md drift.

## Behaviour

1. Load the `context-verify` skill for the full verification framework and scoring rubric
2. Run all verification checks against existing context files
3. Calculate and report the context health score

## Arguments

- **No arguments**: Run full verification with interactive report
- `ci`: Output machine-readable format for CI/CD pipelines (exit code 1 on failures)
- `ci --min-score N`: Fail if score falls below threshold N

## Output

```
AI Context Health: 85/100 (B — Minor tuning needed)

Breakdown:
  Line Budget:      25/25  ✓
  Signal Quality:   20/25  (-3 AGENTS.md has file tree, -2 dependency listing)
  Path Accuracy:    18/20  (-2 .cursorrules references src/old.ts)
  Consistency:      15/15  ✓
  Freshness:         7/15  (-2 MEMORY.md not promoted, -3 copilot-instructions.md stale, -3 .windsurfrules stale)

To reach grade A (90+): Remove file tree from AGENTS.md (+3), fix stale path (+2).
```
