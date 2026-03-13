# Documentation Awareness

When working on a project with PitchDocs installed, recognise documentation-relevant moments and suggest the appropriate command. This is advisory — never block work, just surface the right tool at the right time.

## Documentation Trigger Map

| You Notice | Suggest |
|-----------|---------|
| New feature added (exports, commands, routes, endpoints) | `/pitchdocs:features audit` then `/pitchdocs:readme` |
| Workflow or CLI args changed | `/pitchdocs:user-guide` |
| Version bump or new git tag | `/pitchdocs:doc-refresh` |
| Release prep or changelog discussion | `/pitchdocs:changelog` then `/pitchdocs:launch` |
| Merging a release-please PR | Remind: run activation evals first |
| Project going public or thin README | `/pitchdocs:readme` |
| Missing docs (no `docs/guides/`, no llms.txt) | `/pitchdocs:docs-audit` |
| User asks about positioning or "why use this?" | `/pitchdocs:features benefits` |
| README section exceeds 2 paragraphs or 8-row table | Suggest delegating to `docs/guides/` |
| User asks "are my docs up to date?" or session start | Launch `docs-freshness` agent |

## When NOT to Suggest

- During debugging, testing, or CI troubleshooting — stay focused on the immediate problem
- When the user is mid-flow on a complex coding task — wait for a natural pause
- When the same suggestion was already made this session — don't repeat
- For trivial code changes (typos, formatting) that don't affect documentation
