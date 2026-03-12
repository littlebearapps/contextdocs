---
description: "Validate AI context file quality — signal-to-noise ratio, line budgets, stale paths, AGENTS-to-bridge consistency, and context health scoring: $ARGUMENTS"
argument-hint: "[ci|ci --min-score N] or no args for interactive report"
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
---

# /context-verify

Validate the quality and freshness of AI context files in the current project. Scores signal-to-noise ratio, checks line budgets, detects stale paths, verifies that bridge files stay consistent with `AGENTS.md`, and flags MEMORY.md drift.

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
AI Context Health: 82/100 (B — Minor tuning needed)

Breakdown:
  Line Budget:      18/20  (-2 CLAUDE.md bridge restates AGENTS commands)
  Signal Quality:   17/20  (-3 AGENTS.md has file tree)
  Path Accuracy:    18/20  (-2 .cursorrules references src/old.ts)
  Consistency:      13/15  (-2 CLAUDE.md missing @AGENTS.md)
  Freshness:        12/15  (-3 copilot-instructions.md stale 90+ days)
  Context Load:     10/10  ✓

Checks: 13 run (line budgets, signal quality, stale paths, AGENTS-to-bridge consistency,
MEMORY.md drift, Context Guard status, context load, @import paths, rule path-scopes,
rule symlinks, .mcp.json, agent memory hygiene, plugin manifest)

To reach grade A (90+): Remove file tree from AGENTS.md (+3), restore @AGENTS.md import (+2), fix stale path (+2).
```
