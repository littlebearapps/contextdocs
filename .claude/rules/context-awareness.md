# Context Awareness

When working on a project with ContextDocs installed, recognise moments when AI context files may need attention and suggest the appropriate command. This is advisory — never block work, just surface the right tool at the right time.

## Context Trigger Map

| You Notice | Suggest | Why |
|-----------|---------|-----|
| Structural files changed (skills, commands, agents, rules, config) | `/contextdocs:ai-context audit` | AI context files may reference stale paths or counts |
| New dependency or framework added | `/contextdocs:ai-context` | Context files should reflect the current tech stack |
| MEMORY.md contains repeated project conventions or stable patterns | `/contextdocs:ai-context promote` | Promote stable auto-memory insights to CLAUDE.md where the whole team benefits |
| Test runner, linter, or formatter changed | `/contextdocs:ai-context update` | Commands in context files may reference outdated tooling |
| Source files renamed or moved | `/contextdocs:context-verify` | Context files may reference stale paths |
| Project going public or onboarding new contributors | `/contextdocs:ai-context init` | Bootstrap context files so every AI tool understands the project from day one |
| Pre-release or version bump | `/contextdocs:context-verify` | Verify context files are current before shipping |

## When NOT to Suggest

- During debugging, testing, or CI troubleshooting — stay focused on the immediate problem
- When the user is mid-flow on a complex coding task — wait for a natural pause
- When the same suggestion was already made this session — don't repeat
- For trivial code changes (typos, formatting) that don't affect context files
