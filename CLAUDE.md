# ContextDocs

Generate, maintain, and audit AI IDE context files using the Signal Gate principle. ContextDocs is a Claude Code plugin (pure Markdown, zero runtime dependencies) with 3 skills, 3 commands, 2 quality rules, and 5 opt-in hooks.

## Project Architecture

This is a **100% Markdown-based plugin** — no JavaScript, no Python, no build step. All knowledge lives in structured YAML+Markdown files:

```
.claude-plugin/plugin.json      → Plugin manifest (name, version, keywords)
.claude/skills/*/SKILL.md       → 3 reference knowledge modules (loaded on-demand)
.claude/rules/context-quality.md → AI context quality standards (auto-loaded every session)
.claude/rules/context-awareness.md → Context trigger map (auto-loaded every session)
commands/*.md                   → 3 slash command definitions
hooks/*.sh                      → 5 opt-in hook scripts (Claude Code only)
```

## Conventions

- **Australian English**: realise, colour, behaviour, licence (noun), license (verb)
- **Conventional Commits**: `feat:`, `fix:`, `docs:`, `chore:` — release-please automates versioning

## Key Files

| File | Purpose |
|------|---------|
| `plugin.json` | Version, description, keywords — update on every release |
| `context-quality.md` | Quality rule auto-loaded every session — cross-file consistency, path verification, sync points |
| `context-awareness.md` | Trigger map rule — suggests ContextDocs commands when context-relevant work is detected |

## When Modifying This Plugin

1. **Adding a skill**: Create `.claude/skills/<name>/SKILL.md`, add a corresponding command in `commands/<name>.md`, update README.md, AGENTS.md, and llms.txt
2. **Adding a command**: Create `commands/<name>.md` with YAML frontmatter, update commands tables in README.md, AGENTS.md, and llms.txt
3. **Changing quality standards**: Edit `.claude/rules/context-quality.md` — propagates automatically
4. **Bumping version**: Handled automatically by release-please from conventional commit messages

## Relationship to PitchDocs

ContextDocs was extracted from [PitchDocs](https://github.com/littlebearapps/pitchdocs) v1.19.3 to follow the LBA microtool philosophy. PitchDocs handles public-facing documentation (README, CHANGELOG, ROADMAP, user guides). ContextDocs handles AI IDE context files. Both work independently; both cross-link where relevant.
