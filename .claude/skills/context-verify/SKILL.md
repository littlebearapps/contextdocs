---
name: context-verify
description: Validates AI context file quality — signal-to-noise ratio, line budgets, stale paths, cross-file consistency, discoverable content detection, and MEMORY.md drift. Scores context health and integrates with CI. Use to catch context file decay before it reaches your repo.
---

# Context Verifier

## Philosophy

Generating context files is solved — the `ai-context` skill handles that. Preventing context file decay is not. This skill validates that AI context files remain accurate, lean, and consistent over time. Research shows overstuffed context files reduce AI task success by ~3% (ETH Zurich, 2026).

## Verification Checks

### 1. Line Budget Compliance

Check line counts against Signal Gate budgets. Estimate tokens alongside: lines × 4 (average tokens per line of Markdown).

```bash
# Check line counts and estimate tokens against budgets
for f in CLAUDE.md AGENTS.md .cursorrules .github/copilot-instructions.md .windsurfrules .clinerules GEMINI.md; do
  [ -f "$f" ] && lines=$(wc -l < "$f") && echo "$f: $lines lines (~$((lines * 4)) tokens)"
done
```

| File | Warning | Over Budget |
|------|---------|-------------|
| CLAUDE.md | >80 lines | >120 lines |
| AGENTS.md | >120 lines | >160 lines |
| Other context files | >60 lines | >100 lines |

### 2. Discoverable Content Detection

Directory listings, file trees, and dependency lists waste tokens because agents discover these on their own:

```bash
# Grep for file tree characters and common discoverable patterns
grep -c -E '(├──|└──|│   |src/.*—|tests/.*—)' CLAUDE.md AGENTS.md 2>/dev/null
```

Flag each instance with specific line numbers. Common discoverable patterns:
- ASCII file trees (├──, └──, │)
- "Project Structure" sections with directory listings
- Dependency lists that mirror package.json/pyproject.toml
- Architecture descriptions visible from reading source code

### 3. Stale Path Detection

Every backtick-quoted path in a context file must exist on disk:

```bash
# Extract backtick-quoted paths and verify
grep -oE '`[^`]*\.[a-z]+`' CLAUDE.md AGENTS.md 2>/dev/null | tr -d '`' | while read -r p; do
  [ -f "$p" ] || echo "STALE: $p"
done
```

### 4. Cross-File Consistency

Key commands (test, build, deploy) must match across all context files. Extract command strings from each file and compare. Flag any mismatches between CLAUDE.md, AGENTS.md, and other context files.

### 5. MEMORY.md Drift

If a MEMORY.md exists for this project, check whether it contains conventions not yet promoted to CLAUDE.md:

```bash
# Locate project MEMORY.md
find ~/.claude -name "MEMORY.md" -path "*$(basename $(pwd))*" 2>/dev/null
```

Check for convention-like patterns (lines starting with "Always", "Never", "Use") that don't appear in CLAUDE.md.

### 6. Context Guard Status

Check if Context Guard hooks are installed and healthy:

```bash
# Check for hook scripts
ls .claude/hooks/context-*.sh 2>/dev/null

# Check settings.json for hook entries
grep -l "context-" .claude/settings.json 2>/dev/null
```

## Scoring

| Dimension | Max | Deductions |
|-----------|-----|-----------|
| Line Budget | 25 | -2 per file over warning, -5 per file over budget |
| Signal Quality | 25 | -1 per discoverable content instance (max -5), -3 if "Project Structure" section present |
| Path Accuracy | 20 | -2 per stale path (max -10) |
| Consistency | 15 | -3 if test/build/deploy commands differ between context files |
| Freshness | 15 | -2 if MEMORY.md conventions not promoted, -3 per context file not updated in 90+ days |

### Score Calculation

```
score = 100
for each check result:
  apply deductions from the table above
score = max(0, score)
grade = lookup(score)
```

### Grade Bands

| Score | Grade | Label |
|-------|-------|-------|
| 90–100 | A | Lean and current |
| 80–89 | B | Minor tuning needed |
| 70–79 | C | Needs attention |
| 60–69 | D | Significant drift |
| <60 | F | Overhaul recommended |

### Report Format

```
AI Context Health: 82/100 (B — Minor tuning needed)

Breakdown:
  Line Budget:      23/25  (-2 AGENTS.md: 135 lines ~540 tokens, over 120-line warning)
  Signal Quality:   22/25  (-3 CLAUDE.md has "Project Structure" section)
  Path Accuracy:    18/20  (-2 .cursorrules references stale path)
  Consistency:      15/15  ✓
  Freshness:        4/15   (-2 MEMORY.md not promoted, -3 copilot-instructions.md stale 95 days, -3 .windsurfrules stale 110 days, -3 .clinerules stale 120 days)

To reach grade A (90+): Remove "Project Structure" from CLAUDE.md (+3), fix stale path in .cursorrules (+2).
```

## CI Integration

When run with `ci` argument, output machine-readable format and exit code 1 on failures:

```bash
# GitHub Actions
echo "CONTEXTDOCS_SCORE=82" >> "$GITHUB_OUTPUT"
echo "CONTEXTDOCS_GRADE=B" >> "$GITHUB_OUTPUT"
```

Accept `--min-score N` to fail the CI job if the score falls below a threshold.

## Anti-Patterns

- **Don't ignore line budget warnings** — overstuffed files actively harm AI performance
- **Don't include discoverable content** — agents read source code, manifests, and file trees on their own
- **Don't let context files drift silently** — run verification after every release or use Context Guard hooks
- **Don't check context files in CI without also verifying paths** — stale path references cause silent confusion for AI tools
