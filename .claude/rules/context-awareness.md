# Context Awareness

Recognise when AI context files may need attention and suggest the appropriate command. Advisory only — never block work.

## Context Trigger Map

| You Notice | Suggest |
|-----------|---------|
| Structural files changed (skills, commands, agents, rules, config) | `/contextdocs:ai-context audit` |
| New dependency or framework added | `/contextdocs:ai-context` |
| MEMORY.md contains stable patterns | `/contextdocs:ai-context promote` |
| Test runner, linter, or formatter changed | `/contextdocs:ai-context update` |
| Source files renamed or moved | `/contextdocs:context-verify` |
| Project going public or onboarding contributors | `/contextdocs:ai-context init` |
| Pre-release or version bump | `/contextdocs:context-verify` |

## Autonomous Actions (Claude Code Only)

When Context Guard hooks are installed, act on these triggers without waiting for user instruction:

| Trigger | Action |
|---------|--------|
| Stop hook reports context drift | Launch `context-updater` agent before ending session |
| Commit guard blocks a commit | Launch `context-updater` agent, stage files, retry commit |
| PostToolUse reports structural change AND current task is complete | Launch `context-updater` agent before reporting completion |

The agent (`.claude/agents/context-updater.md`) applies surgical edits, not full regeneration. Do not launch during debugging, mid-task, or for trivial changes.

## When NOT to Suggest

- During debugging, testing, or CI troubleshooting
- Mid-flow on a complex coding task — wait for a natural pause
- Same suggestion already made this session
