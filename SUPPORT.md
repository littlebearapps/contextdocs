# Support

Need help with ContextDocs? Here's how to get it.

## Getting Help

- **GitHub Issues** — [Open an issue](https://github.com/littlebearapps/contextdocs/issues/new/choose) for bugs, feature requests, or questions about generated context files
- **Existing Issues** — Browse [existing issues](https://github.com/littlebearapps/contextdocs/issues) — your question may already be resolved
- **Contributing Guide** — See [CONTRIBUTING.md](CONTRIBUTING.md) to improve skills, fix hook scripts, or add new context file types

## Common Questions

### Context files are too long or contain discoverable content

ContextDocs uses the Signal Gate principle — only include what agents cannot discover on their own. If generated files contain directory listings, file trees, or architecture overviews, run:

```bash
/contextdocs:context-verify
```

This scores your context files 0–100 and flags discoverable content that should be removed.

### Context Guard hooks aren't triggering

1. Check hook status: `/contextdocs:context-guard status`
2. Verify hooks are in `.claude/settings.json` — they need explicit entries
3. Context Guard hooks are Claude Code only — they don't work in OpenCode, Cursor, or other tools

### Content filter blocks generation

Claude Code's API may return HTTP 400 when generating `CODE_OF_CONDUCT.md`, `SECURITY.md`, or `LICENSE` files. This is a [known upstream issue](https://github.com/anthropics/claude-code/issues/2111). ContextDocs includes a content filter guard hook that warns before attempting to write these files.

### Using with other AI tools

ContextDocs works with Claude Code and OpenCode natively. The generated context files (.cursorrules, .windsurfrules, etc.) work with their respective tools automatically. See the [Getting Started guide](docs/guides/getting-started.md) for setup.

## Contact

- **Email**: [hello@littlebearapps.com](mailto:hello@littlebearapps.com)
- **Security issues**: See [SECURITY.md](SECURITY.md) for responsible disclosure

## Response Times

- Bug reports: triaged within 48 hours
- Feature requests: reviewed within 1 week
- Security issues: acknowledged within 48 hours, resolved within 7 days
