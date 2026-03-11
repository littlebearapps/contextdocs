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
| context-guard-stop | 10 | 8 | 0 |
| **Total** | **65** | **65** | **0** |

### Other Checks

| Check | Result |
|-------|--------|
| Token budgets | PASS |
| Banned phrases | CLEAN |
| Frontmatter validation | PASS |
| llms.txt validation | PASS |

## Phase 2: Activation Evals

[Results after running]

## Phase 3: CI Integration

[Updated after PR passes]
