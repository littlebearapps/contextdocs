# ContextDocs v2.0 Implementation Plan — Closing the Claude Code Feature Gap

## Context

ContextDocs v1.3.0 covers the core Claude Code context file system (CLAUDE.md, AGENTS.md, rules, hooks, agents, skills) but a gap analysis found **40+ missing features** across 8 categories. Claude Code ships 4–7 releases/week with no stability policy, so ContextDocs also needs an upstream freshness strategy. This plan addresses both.

---

## Current Token Budget Headroom

| File | Current chars | Budget | Headroom |
|------|--------------|--------|----------|
| ai-context SKILL.md | 4,719 | 8,000 | 41% |
| context-guard SKILL.md | 5,126 | 8,000 | 36% |
| context-verify SKILL.md | 3,305 | 8,000 | 59% |
| context-quality.md (rule) | 1,622 | 2,000 | 19% |
| context-awareness.md (rule) | 1,610 | 2,000 | 19% |
| context-updater.md (agent) | 4,041 | 10,000 | 60% |
| docs-freshness.md (agent) | 4,601 | 10,000 | 54% |

Companion files (`SKILL-*.md`) have a 12,000-char budget. The test infrastructure already supports them.

---

## Key Design Decisions

**D1: Companion reference files.** The ai-context and context-guard skills don't have enough headroom for all new content. Use `SKILL-reference.md` companion files (already supported by `check-token-budgets.sh`). Main SKILL.md stays as the workflow orchestrator; companion holds the full feature catalogues.

**D2: Agent frontmatter — do both.** Add useful fields to ContextDocs' own agents (`maxTurns`, `disallowedTools`, `isolation`) AND document all fields in the ai-context reference so the skill generates correct frontmatter for user projects.

**D3: Hook documentation scope.** Document all 17 hook events in the companion reference for completeness, but only implement new hooks for the 1–2 most impactful events (SessionStart for health check).

**D4: Plugin system features.** Document LSP, output styles, and plugin settings in the reference (for user projects) but don't implement them in ContextDocs itself — it's a pure Markdown plugin.

**D5: Upstream freshness.** Enhance existing `check-upstream.yml` with a weekly Claude Code monitoring job. Don't create a new workflow.

**D6: Split large companion.** If `SKILL-reference.md` exceeds 12,000 chars, split into two: `SKILL-reference-agents.md` and `SKILL-reference-platform.md`.

---

## Phase 1: Agent Frontmatter & Companion Infrastructure (→ v1.4.0)

**Goal:** Establish companion file pattern, upgrade agent definitions, document all agent/skill frontmatter fields.

### Files to Create

1. **`.claude/skills/ai-context/SKILL-reference.md`** (~9,000 chars)
   - Complete agent frontmatter catalogue: `name`, `description`, `tools`, `disallowedTools`, `model`, `memory`, `isolation`, `permissionMode`, `maxTurns`, `mcpServers`, `skills`, `background`, `hooks` — with type, default, and when-to-use for each
   - Complete skill frontmatter catalogue: `context: fork`, `agent`, `disable-model-invocation`, `user-invocable`, `hooks`, `model`, `allowed-tools`
   - Variable substitution reference: `$ARGUMENTS`, `$ARGUMENTS[N]`, `$N`, `${CLAUDE_SESSION_ID}`, `${CLAUDE_SKILL_DIR}`
   - Dynamic injection syntax: `` !`command` ``
   - Bundled resources pattern: `scripts/`, `references/`, `assets/`
   - Agent memory directories: `.claude/agent-memory/`, `.claude/agent-memory-local/`, `~/.claude/agent-memory/`

### Files to Modify

2. **`.claude/skills/ai-context/SKILL.md`** (+200 chars)
   - Add pointer to companion reference under Anti-Patterns section

3. **`.claude/agents/context-updater.md`** — Add frontmatter:
   - `maxTurns: 10` (prevent runaway)
   - `disallowedTools: [WebSearch, WebFetch]` (no internet needed)

4. **`.claude/agents/docs-freshness.md`** — Add frontmatter:
   - `maxTurns: 8` (lightweight check)
   - `disallowedTools: [Write, Edit, WebSearch, WebFetch]` (enforce read-only)

### Propagation Updates

5. `AGENTS.md` — Update agent descriptions to note new frontmatter
6. `llms.txt` — Add companion file reference
7. `llms-full.txt` — Regenerate

### Tests

8. `tests/validate-frontmatter.py` — Add optional field validation for new agent frontmatter keys

**Commit:** `feat: add ai-context companion reference and upgrade agent definitions`

---

## Phase 2: CLAUDE.md Advanced Features (→ v1.5.0)

**Goal:** Teach ai-context about @import, directory walking, claudeMdExcludes, managed policy.

### Files to Modify

1. **`.claude/skills/ai-context/SKILL.md`** (+400 chars)
   - New section "CLAUDE.md Advanced Features" with brief descriptions and pointer to companion

2. **`.claude/skills/ai-context/SKILL-reference.md`** (+1,500 chars)
   - `@import` syntax: `@path/to/file.md`, max 5 hops, relative path resolution
   - Directory walking: ancestor CLAUDE.md concatenated, subdirectory on-demand
   - `claudeMdExcludes`: array of glob patterns in settings
   - Managed policy CLAUDE.md: enterprise, read-only, cannot be overridden
   - Generation guidance: when to recommend @import vs subdirectory CLAUDE.md

3. **`.claude/skills/context-verify/SKILL.md`** (+300 chars)
   - Check 8: @import path validation (verify targets exist, -2 per broken import)

### Propagation Updates

4. `AGENTS.md` — Update ai-context description
5. `llms.txt` — Update

**Commit:** `feat: add CLAUDE.md @import, directory walking, and claudeMdExcludes support`

---

## Phase 3: Rules System Expansion (→ v1.6.0)

**Goal:** Document path-scoped rules, recursive subdirectories, user-level rules, symlinks.

### Files to Modify

1. **`.claude/skills/ai-context/SKILL-reference.md`** (+1,200 chars)
   - Path-scoped rules: `paths:` YAML frontmatter with glob patterns
   - Recursive discovery: `.claude/rules/frontend/*.md`
   - User-level rules: `~/.claude/rules/` loaded before project rules
   - Symlink support for shared rules

2. **`.claude/skills/context-verify/SKILL.md`** (+400 chars)
   - Check 9: Rule path-scope validation (verify `paths:` globs match existing files)
   - Check 10: Rule symlink targets exist

3. **`.claude/rules/context-quality.md`** (+100 chars)
   - Note about path-scoped rules in sync points

### Propagation Updates

4. `AGENTS.md`, `llms.txt`

**Commit:** `feat: add path-scoped rules, recursive subdirectories, and symlink support`

---

## Phase 4: Hook System Expansion (→ v1.7.0)

**Goal:** Document all 17 hook events, 4 handler types, advanced features. Add SessionStart hook.

### Files to Create

1. **`.claude/skills/context-guard/SKILL-reference.md`** (~10,500 chars)
   - **All 17 hook event types** with stdin schema and expected output:
     - Currently documented: PreToolUse, PostToolUse, Stop
     - Session lifecycle: SessionStart, SessionEnd
     - Permission: PermissionRequest, UserPromptSubmit
     - Tool errors: PostToolUseFailure
     - Agent lifecycle: SubagentStart, SubagentStop
     - Task tracking: TaskCompleted, Notification
     - Team: TeammateIdle
     - Config: ConfigChange, InstructionsLoaded
     - Worktree: WorktreeCreate, WorktreeRemove
     - Compaction: PreCompact
   - **All 4 handler types**: command (bash), http (POST webhook), prompt (single-turn LLM), agent (agentic verifier with tools)
   - **Hook features**: `updatedInput` (modify tool params), `CLAUDE_ENV_FILE` (persist env vars), `async: true` (background), `once: true` (fire once), `timeout`, matcher regex patterns
   - **Hook snapshots**: captured at startup, `/hooks` to review changes

2. **`.claude/hooks/context-session-start.sh`** (~60 lines)
   - SessionStart hook: quick context health check
   - Warns if aggregate context load exceeds threshold
   - Lightweight — no full verification, just critical checks

### Files to Modify

3. **`.claude/skills/context-guard/SKILL.md`** (+300 chars)
   - Add pointer to companion reference
   - Add SessionStart hook to Components table

4. **`commands/context-guard.md`** (+200 chars)
   - Update install instructions to include SessionStart hook

### Propagation Updates

5. `AGENTS.md` — Update hook count (5→6), context-guard description
6. `llms.txt` — Add companion reference, new hook

### Tests

7. `tests/test-hooks.sh` — Add SessionStart hook test cases

**Commit:** `feat: add complete hook system reference and SessionStart health check hook`

---

## Phase 5: Context-Verify Expansion (→ v1.8.0)

**Goal:** Add .mcp.json validation, agent memory directory checks, plugin manifest checks.

### Files to Modify

1. **`.claude/skills/context-verify/SKILL.md`** (+600 chars)
   - Check 11: .mcp.json validation (structure, server entries)
   - Check 12: Agent memory directory hygiene (warn if tracked in git)
   - Check 13: Plugin manifest completeness (if .claude-plugin/plugin.json exists)
   - Update scoring to fold new checks into existing dimensions

2. **`commands/context-verify.md`** (+200 chars)
   - Update output example

### Propagation Updates

3. `AGENTS.md`, `llms.txt`

**Commit:** `feat: add .mcp.json, agent memory, and plugin manifest validation`

---

## Phase 6: Upstream Freshness Strategy (→ v1.9.0)

**Goal:** Automated monitoring of Claude Code releases and schema changes.

### Research Findings — Claude Code Update Cadence

| Metric | Value |
|--------|-------|
| Release frequency | 4–7 per week (~daily) |
| Current version | v2.1.74 (2026-03-12) |
| Breaking change frequency | ~1–2 per month (undocumented) |
| Stability policy | None — no deprecation notices, no schema guarantees |
| Latest breaking change | Task→Agent tool rename (v2.1.63) changed hook JSON payloads silently |

### Monitoring Sources (ranked)

| Source | URL | Update frequency |
|--------|-----|-----------------|
| GitHub Atom feed | `github.com/anthropics/claude-code/releases.atom` | Per-release |
| Official changelog | `code.claude.com/docs/en/changelog` | Per-release |
| Docs index (llms.txt) | `code.claude.com/docs/llms.txt` | When pages added/removed |
| Settings JSON schema | `json.schemastore.org/claude-code-settings.json` | When settings change |
| Releasebot | `releasebot.io/updates/anthropic/claude-code` | Per-release, multi-channel |

### Recommended Cadence

- **Weekly**: Check for new Claude Code releases and diff the settings schema
- **Fortnightly**: Diff the documentation pages (hooks, skills, agents, plugins)
- **Per ContextDocs release**: Verify all documented features still work

### Implementation

1. **`upstream-versions.json`** — Add Claude Code entry:
   ```json
   "claude-code": {
     "check_type": "github-release",
     "repo": "anthropics/claude-code",
     "last_verified": "2026-03-12",
     "last_seen_version": "2.1.74",
     "sources": ["releases.atom", "changelog", "llms.txt", "settings-schema"]
   }
   ```

2. **`.github/workflows/check-upstream.yml`** — Add `check-claude-code` job:
   - Fetch latest release tag via `gh api`
   - Compare against pinned version in `upstream-versions.json`
   - Fetch settings JSON schema, check for new hook events or frontmatter fields
   - If drift detected: create/update GitHub issue with `upstream-drift` label
   - Schedule: weekly (cron `0 9 * * 1`)

3. **`.claude/rules/context-awareness.md`** (+100 chars)
   - Add trigger: "When upstream-drift issue is open" → review companion references

**Commit:** `feat: add Claude Code release and schema monitoring`

---

## Phase 7: Plugin System Documentation (→ v1.10.0)

**Goal:** Document LSP, output styles, plugin settings, installation scopes for user guidance.

### Files to Modify

1. **`.claude/skills/ai-context/SKILL-reference.md`** (+1,500 chars)
   - `.lsp.json` manifest for LSP server support
   - `outputStyles/` directory convention
   - `settings.json` plugin settings and defaults
   - Installation scopes: user/project/local/managed
   - Note: If companion exceeds 12,000 chars, split into `SKILL-reference-agents.md` and `SKILL-reference-platform.md`

### Propagation Updates

2. `AGENTS.md`, `llms.txt`

**Commit:** `feat: add plugin system documentation to ai-context reference`

---

## Phase Summary

| Phase | Version | Scope | Key Deliverables | Risk |
|-------|---------|-------|-----------------|------|
| 1 | v1.4.0 | Agent/skill frontmatter | Companion file pattern, agent upgrades, full frontmatter catalogue | Low |
| 2 | v1.5.0 | CLAUDE.md advanced | @import, directory walking, claudeMdExcludes, managed policy | Low |
| 3 | v1.6.0 | Rules system | Path-scoped rules, recursive dirs, user-level rules, symlinks | Low |
| 4 | v1.7.0 | Hook system | 17 events, 4 handler types, SessionStart hook | Medium — verify events exist |
| 5 | v1.8.0 | Verify expansion | .mcp.json, agent memory, plugin manifest validation | Low |
| 6 | v1.9.0 | Upstream freshness | Weekly monitoring, schema diffing, drift issues | Low |
| 7 | v1.10.0 | Plugin system | LSP, output styles, settings, scopes (documentary) | Low |

Each phase is independently releasable. Dependencies flow forward (Phase 1 patterns used by all later phases). No phase requires a later phase.

---

## Token Budget Impact (cumulative)

| File | Current | Final Est. | Budget | Status |
|------|---------|-----------|--------|--------|
| ai-context SKILL.md | 4,719 | ~5,319 | 8,000 | OK |
| ai-context SKILL-reference.md | 0 | ~13,200 | 12,000 | Split if needed |
| context-guard SKILL.md | 5,126 | ~5,426 | 8,000 | OK |
| context-guard SKILL-reference.md | 0 | ~10,500 | 12,000 | OK |
| context-verify SKILL.md | 3,305 | ~4,805 | 8,000 | OK |
| context-quality.md | 1,622 | ~1,722 | 2,000 | Tight but OK |
| context-awareness.md | 1,610 | ~1,710 | 2,000 | Tight but OK |
| context-updater.md | 4,041 | ~4,191 | 10,000 | OK |
| docs-freshness.md | 4,601 | ~4,751 | 10,000 | OK |

---

## Verification Plan

After each phase:
1. Run `bash tests/check-token-budgets.sh` — verify no budget violations
2. Run `bash tests/validate-llms-txt.sh` — verify no orphaned components
3. Run `python3 tests/validate-frontmatter.py` — verify frontmatter validity
4. Run `npx typos` — verify Australian English spelling
5. Manual: `/contextdocs:context-verify` — score should remain B+ or above
6. Manual: Verify new content follows Signal Gate principle

After Phase 4 specifically:
- Run `bash tests/test-hooks.sh` — verify new hook tests pass
- Manually test SessionStart hook in a Claude Code session

After Phase 6:
- Verify `check-upstream.yml` workflow runs successfully
- Confirm it detects the current Claude Code version correctly

---

## Risk Register

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Hook events renamed/removed upstream | High | Medium | Phase 6 monitoring; companion reference marks stability |
| Companion file exceeds budget | Medium | Low | Split into two files; budget is advisory |
| New hook events don't exist in current CC version | Medium | Medium | Mark undocumented events; only implement confirmed ones |
| PitchDocs shared rules already over budget | Known | Low | PitchDocs owns those; flag but don't fix |
| Activation evals regress | Low | Medium | Run evals after each phase; changes are additive |
| Plugin update cache bug ([#32983](https://github.com/anthropics/claude-code/issues/32983)) | Known | Low | Bump version in plugin.json for each phase |
