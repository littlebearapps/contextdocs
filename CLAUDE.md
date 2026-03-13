# ContextDocs

**Canonical description (use this in all listings and submissions):**
> Your AI agent maintains its own context files — a Claude Code plugin with an AGENTS-first model that covers Codex, Copilot, Cursor, Gemini, and 3 more tools.

Pure Markdown Claude Code plugin — no JavaScript, no Python, no build step, no runtime dependencies. Signal Gate filtering, Context Guard hooks, and 0-100 health scoring.

## Commands

- **Token budget test**: `bash tests/check-token-budgets.sh`
- **llms.txt validation**: `bash tests/validate-llms-txt.sh`
- **Spell check**: `npx typos` (config: `_typos.toml`, Australian English)
- **Frontmatter lint**: `python3 tests/validate-frontmatter.py`

## Conventions

- **Australian English**: realise, colour, behaviour, licence (noun), license (verb)
- **Conventional Commits**: `feat:`, `fix:`, `docs:`, `chore:` — release-please automates versioning
- **Line budgets**: CLAUDE.md bridge <80, AGENTS.md <120, other bridge files <60

## Architecture

- **AGENTS-first generation**: `AGENTS.md` is the canonical shared context for commands, conventions, constraints, and security notes
- **Thin bridges**: `CLAUDE.md`, `.cursorrules`, Copilot instructions, `.clinerules`, `.windsurfrules`, and `GEMINI.md` should add only tool-specific behaviour
- **Compatibility bridges**: `.windsurfrules` and `GEMINI.md` remain generated for now for tool compatibility

## When Modifying

- **Add a skill**: Create `.claude/skills/<name>/SKILL.md` + `commands/<name>.md`, update README.md, AGENTS.md, llms.txt, and AGENTS-first generation guidance if shared output behaviour changed
- **Add a command**: Create `commands/<name>.md` with YAML frontmatter, update README.md, AGENTS.md, llms.txt
- **Add an agent**: Create `.claude/agents/<name>.md` with frontmatter, update AGENTS.md, llms.txt, context-guard SKILL.md
- **Change quality standards**: Edit `.claude/rules/context-quality.md` — propagates automatically
- **Change shared conventions**: Update `AGENTS.md` first, then only the bridge docs whose tool-specific notes change
- **Bump version**: Handled by release-please from conventional commit messages

## Key Files

| File | Purpose |
|------|---------|
| `AGENTS.md` | Canonical shared product context — inventory, command model, and AGENTS-first architecture |
| `.claude-plugin/plugin.json` | Plugin manifest — name, version, keywords |
| `.claude/rules/context-quality.md` | Auto-loaded quality rule — AGENTS-to-bridge consistency, path verification, sync points |
| `.claude/rules/context-awareness.md` | Auto-loaded trigger map — suggests ContextDocs commands when relevant, includes autonomous action triggers |
| `.claude/agents/context-updater.md` | Autonomous agent — launched by hooks to update stale context files with an AGENTS-first workflow |
| `.claude/agents/docs-freshness.md` | Read-only agent — checks documentation freshness, suggests PitchDocs commands *(PitchDocs)* |
| `.claude/rules/doc-standards.md` | Auto-loaded quality rule — 4-Question Test, Lobby Principle, banned phrases *(PitchDocs)* |
| `.claude/rules/docs-awareness.md` | Auto-loaded trigger map — suggests PitchDocs commands when docs-relevant work is detected *(PitchDocs)* |

## Known Limitations

- **Headless mode skill activation**: Skills don't reliably auto-trigger via `claude -p`. This is a Claude Code platform issue ([anthropics/claude-code#32184](https://github.com/anthropics/claude-code/issues/32184)), not a ContextDocs bug. Interactive mode works correctly. Activation evals using `claude -p` will show artificially low pass rates.

## Relationship to PitchDocs

ContextDocs was extracted from [PitchDocs](https://github.com/littlebearapps/pitchdocs) v1.19.3. PitchDocs handles public-facing docs (README, CHANGELOG, ROADMAP). ContextDocs handles AI IDE context files. Both work independently.
