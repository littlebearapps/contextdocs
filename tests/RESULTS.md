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

### Run 1: `run-20260311-130208.json` (baseline)

**Model**: haiku | **Overall**: 6/20 (30%)

Used prefixed commands (`/contextdocs:ai-context`). CLI parser returned "Unknown skill" — project-local plugins don't register with prefixed namespace.

### Run 2: `run-20260311-133703.json` (after #5 fix)

**Model**: haiku | **Overall**: 10/24 (41.6%)

Fixed false positive detection — cross-plugin activations (PitchDocs) no longer count as ContextDocs failures.

### Run 3: `run-20260311-141542.json` (after #3, #4, #5 fixes)

**Model**: haiku | **Runs per case**: 3 | **Overall**: 23/60 (38.3%)

Switched to unprefixed commands (`/ai-context`). Strengthened NL trigger descriptions.

| Category | Pass | Total | Rate |
|----------|------|-------|------|
| Slash commands | 2 | 30 | 6.7% |
| NL triggers | 6 | 15 | 40% |
| Negative tests | 15 | 15 | 100% |
| **Overall** | **23** | **60** | **38.3%** |

Per-run breakdown: Run 1: 30%, Run 2: 35%, Run 3: 50%

### Description Optimisation (skill-creator run_loop)

Ran automated description optimisation via `skill-creator` plugin's `run_loop.py`:
- 5 iterations, 20 eval queries, 3 runs per query per iteration = 300 total `claude -p` invocations
- **Result: 0% trigger rate across all iterations** — no description change improved activation

### Root Cause Analysis

**Confirmed platform limitation**: `claude -p` headless mode does not reliably trigger project-local plugin skills.

- Headless mode skips dynamic project-local command routing (interactive mode handles this)
- Global plugins (PitchDocs, `pitchdocs:` namespace) achieve 69% in same harness
- Tool schema likely absent from LLM context in headless mode for local plugins
- **Multi-model consensus** (GPT-5.4 confidence 8/10, Gemini 3.1 Pro 9/10) confirms this is architectural, not fixable via description changes

### Recommended Workarounds

1. **PTY wrapper** (`pexpect`/`node-pty`) for interactive-mode eval fidelity
2. **Temporary global install** during CI for headless eval compatibility
3. **Split eval types**: registry/parsing, model routing, task success

### Upstream Issue

[anthropics/claude-code#32184](https://github.com/anthropics/claude-code/issues/32184) — "Skill auto-triggering: recall=0% in headless mode" (OPEN, labels: `bug`, `has repro`, `area:skills`). Filed by another user 2026-03-08. We added a comment with our data (300 queries, global vs local comparison, multi-model consensus). No Anthropic response yet. Related: [#26436](https://github.com/anthropics/claude-code/issues/26436) (namespace resolution), [#26227](https://github.com/anthropics/claude-code/issues/26227) (plugins in headless CI).

### Issues Filed

- [#3](https://github.com/littlebearapps/contextdocs/issues/3): Slash command activation in headless mode — platform limitation confirmed
- [#4](https://github.com/littlebearapps/contextdocs/issues/4): ai-context skill weak NL activation — description strengthened, partial improvement
- [#5](https://github.com/littlebearapps/contextdocs/issues/5): Eval runner false positives — fixed, cross-plugin activations filtered

## Phase 3: CI Integration

- `docs-ci.yml` updated with hook tests + banned phrases steps
- `activation-evals.yml` created (manual dispatch)
- `ANTHROPIC_API_KEY` secret configured
