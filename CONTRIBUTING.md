# Contributing to ContextDocs

Thank you for your interest in contributing! This plugin helps manage AI IDE context files, and we'd love your help making it even better.

## Quick Links

- [Open Issues](https://github.com/littlebearapps/contextdocs/issues) — Find something to work on
- [Feature Requests](https://github.com/littlebearapps/contextdocs/issues/new) — Suggest improvements

**Note:** Claude Code's API may return HTTP 400 ("Output blocked by content filtering policy") when generating `CODE_OF_CONDUCT.md`, `SECURITY.md`, or `LICENSE` files. This is a known Claude Code limitation, not a ContextDocs bug. The plugin includes a content filter guard hook that warns before attempting these writes.

---

## How the Plugin Works

This is a Claude Code plugin — a collection of Markdown files and shell scripts that extend Claude's capabilities. There is no compiled code, no build step, and no runtime dependencies.

```
contextdocs/
├── .claude-plugin/plugin.json     # Plugin manifest
├── .claude/
│   ├── rules/context-quality.md   # Context file quality standards
│   ├── rules/context-awareness.md # Context trigger map
│   └── skills/                    # Reference knowledge (loaded on-demand)
│       ├── ai-context/SKILL.md    # Signal Gate generation
│       ├── context-guard/SKILL.md # Hook installation
│       └── context-verify/SKILL.md # Health scoring
├── commands/                      # Slash commands
├── hooks/                         # 5 opt-in shell scripts (Claude Code only)
└── upstream-versions.json         # Pinned AGENTS.md spec version
```

---

## Development Setup

```bash
git clone https://github.com/littlebearapps/contextdocs.git
cd contextdocs
# That's it — no dependencies to install
```

To test changes locally, install from your local path:
```bash
/plugin install /path/to/contextdocs
```

---

## How to Contribute

### Improving Context File Generation

The most impactful contributions improve the quality of generated context files. Look at the skills in `.claude/skills/` — each contains Signal Gate rules, line budgets, and generation templates.

When improving a skill:
1. Show a before/after example of the generated context file
2. Explain why the new version is better for the AI tool consuming it
3. Check that line budgets are still respected

### Improving Hook Scripts

Hook scripts live in `hooks/`. When modifying:
1. Test in a real Claude Code session with `/contextdocs:context-guard install`
2. Verify the hook doesn't break on repos without context files
3. Keep shell scripts POSIX-compatible where possible

### Commit Messages

We use [Conventional Commits](https://www.conventionalcommits.org/):

- `feat: add new skill` — New functionality
- `fix: correct path detection` — Bug fix
- `docs: update readme` — Documentation only
- `chore: update upstream versions` — Maintenance

### Pull Requests

1. Fork the repo and create a branch: `git checkout -b feature/your-feature`
2. Make your changes
3. Commit using conventional commits
4. Push and open a pull request

---

## Testing Your Changes

Since this plugin is primarily Markdown, verify changes by:

1. Install your local copy: `/plugin install /path/to/contextdocs`
2. Run the relevant command against a test repository
3. Check that generated context files respect line budgets
4. Verify hook scripts trigger correctly (if modified)

---

## Code of Conduct

This project follows the [Contributor Covenant v3.0 Code of Conduct](CODE_OF_CONDUCT.md). By participating, you agree to uphold this code.

---

## Questions?

[Open an issue](https://github.com/littlebearapps/contextdocs/issues/new) — we're happy to help.

Thank you for making ContextDocs better!
