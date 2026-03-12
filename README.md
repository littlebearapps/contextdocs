<p align="center">
  <img src="docs/assets/contextdocs-logo-full.svg" height="200" alt="ContextDocs" />
</p>

<p align="center">
  <strong>Keep your AI coding assistants in sync with your codebase — generate, maintain, and audit AGENTS-first context for 7 AI tools.</strong>
</p>

<p align="center">
  Give your AI one canonical `AGENTS.md` plus thin bridge files for every major AI coding tool — `CLAUDE.md`, `.cursorrules`, `copilot-instructions.md`, `.windsurfrules`, `.clinerules`, and `GEMINI.md` — from a single codebase scan. Signal Gate filtering strips out what agents already discover on their own. Context Guard hooks enforce freshness. Health scoring catches drift before it costs you tokens. 100% Markdown, zero runtime dependencies.
</p>

<p align="center">
  <a href="CHANGELOG.md"><img src="https://img.shields.io/static/v1?label=version&message=1.3.0&color=blue" alt="Version" /></a> <!-- x-release-please-version -->
  <a href="LICENSE"><img src="https://img.shields.io/github/license/littlebearapps/contextdocs" alt="License" /></a>
  <a href="https://code.claude.com/docs/en/plugins"><img src="https://img.shields.io/badge/Claude_Code-Plugin-D97757?logo=claude&logoColor=white" alt="Claude Code Plugin" /></a>
  <a href="https://opencode.ai/"><img src="https://img.shields.io/badge/OpenCode-Compatible-22c55e" alt="OpenCode Compatible" /></a>
  <a href="https://github.com/littlebearapps/contextdocs/stargazers"><img src="https://img.shields.io/github/stars/littlebearapps/contextdocs?style=flat&color=yellow" alt="GitHub Stars" /></a>
</p>

<p align="center">
  <a href="#-get-started">Get Started</a> · <a href="#-features">Features</a> · <a href="#%EF%B8%8F-how-contextdocs-compares">How It Compares</a> · <a href="#-commands">Commands</a> · <a href="#-use-with-other-ai-tools">Other AI Tools</a> · <a href="CONTRIBUTING.md">Contributing</a>
</p>

---

## ⚡ Get Started

Get your first AI context files generated in under 60 seconds.

### Prerequisites

- [Claude Code](https://code.claude.com/) or [OpenCode](https://opencode.ai/) installed

**Using a different AI tool?** ContextDocs generates plain Markdown files that work with [Codex CLI, Cursor, Windsurf, Cline, and Gemini CLI](#-use-with-other-ai-tools) automatically.

### Install

```bash
# 1. Add the LBA plugin marketplace (once)
/plugin marketplace add littlebearapps/lba-plugins

# 2. Install ContextDocs
/plugin install contextdocs@lba-plugins

# 3. Bootstrap AI context for your project
/contextdocs:ai-context init
```

**Optional — install Context Guard hooks (Claude Code only):**

```bash
# 4. Keep context files in sync as your project evolves
/contextdocs:context-guard install              # Tier 1 (Nudge) — reminds at session end
/contextdocs:context-guard install --tier enforce  # Tier 2 (Enforce) — also blocks commits
```

**Optional — public-facing documentation:**

For README, CHANGELOG, ROADMAP, user guides, and launch artifacts, install [PitchDocs](https://github.com/littlebearapps/pitchdocs) separately. Both plugins work independently and complement each other.

---

## 🚀 What ContextDocs Does

Your AI coding assistant works better when it understands your project's conventions — but overstuffed context files actually make things worse. Research shows bloated context **reduces** AI task success by ~3% and increases token costs by 20% (ETH Zurich, 2026). Most teams either write too much, write the wrong things, or let context files go stale within a week.

ContextDocs solves the full lifecycle. It scans your codebase, generates `AGENTS.md` as the canonical shared context, then creates thin bridge files for 7 AI tools using the **Signal Gate principle** — only what agents cannot discover by reading source code on their own. No directory listings, no file trees, no architecture overviews that agents find themselves. Just the conventions, gotchas, and decisions that actually help.

Then it keeps them fresh: `update` patches drift incrementally, `promote` moves Claude's auto-learned MEMORY.md patterns into CLAUDE.md, `context-verify` scores health 0–100 across 6 dimensions with 13 checks, and Context Guard hooks enforce freshness at session start, session end, and commit time — with the context-updater agent applying fixes automatically.

---

## 🎯 Features

ContextDocs generates AGENTS-first context for 7 AI coding tools from a single codebase scan, applies Signal Gate filtering to strip discoverable content, enforces line budgets (AGENTS.md <120, CLAUDE.md <80, other bridges <60), and scores health 0–100 across 6 dimensions with 13 verification checks. Context Guard hooks catch drift at session start, session end, and commit time.

- 🧠 **Signal Gate filtering** — strips out discoverable content (directory listings, file trees, architecture overviews) so your context files contain only what actually helps AI tools, keeping them lean and under budget
- 📋 **AGENTS-first generation + thin bridges** — shared conventions live once in `AGENTS.md`, while `CLAUDE.md`, Copilot instructions, Cursor rules, Cline rules, and compatibility bridges stay minimal and tool-specific
- 🔄 **Full lifecycle, not just generation** — `init` bootstraps, `update` patches only what drifted, `promote` graduates MEMORY.md patterns to CLAUDE.md, `audit` flags staleness — so context files stay accurate as your project evolves
- ✅ **Health scoring (0–100)** — grades context files across line budget, signal quality, path accuracy, AGENTS-to-bridge consistency, freshness, and aggregate context load — export to CI with `--min-score` so drift never reaches your team
- 🔒 **Context Guard enforcement** — SessionStart health check validates on entry, Tier 1 nudges at session end, Tier 2 blocks commits when context files are stale, so drift gets caught at every stage *(Claude Code only)*
- 🤖 **Autonomous context updates** — the context-updater agent is launched automatically by hooks to update stale files without user intervention, closing the loop from detection to action *(Claude Code only)*
- 🛡️ **Content filter protection** — guards against Claude Code's API filter (HTTP 400) for CODE_OF_CONDUCT, LICENSE, and SECURITY files, so hook installation never gets blocked *(Claude Code only)*
- 📏 **Line budgets that work** — CLAUDE.md <80, AGENTS.md <120, all others <60 — backed by the ETH Zurich finding that shorter, focused context outperforms longer files
- 🗂️ **Path-scoped context rules** — apply different conventions to different directories using glob patterns, so monorepos and multi-platform projects get targeted context per area *(Claude Code only)*
- 📡 **Upstream compatibility tracking** — weekly Claude Code release monitoring and settings schema diffing detect breaking changes before they affect your context files
- 🔌 **Works with 7 AI tools** — Claude Code and OpenCode natively; generated files work with Codex CLI, Cursor, Windsurf, Cline, and Gemini CLI automatically

---

## ⚖️ How ContextDocs Compares

ContextDocs automates what most teams do manually — writing and maintaining AI context files. Compared to hand-writing context files or asking a generic AI prompt, ContextDocs applies Signal Gate filtering, generates canonical `AGENTS.md` plus bridges for 7 tools, enforces line budgets, and keeps files in sync with Context Guard hooks.

| Capability | ContextDocs | Writing Context Files Manually | Generic AI Prompt |
|-----------|-------------|-------------------------------|-------------------|
| Filters out discoverable content | Signal Gate principle — only undiscoverable signals | Requires discipline and AI knowledge | No filtering — dumps everything |
| Generates for multiple AI tools | Canonical `AGENTS.md` + thin bridges from one scan | Write each file separately | One file at a time |
| Keeps files in sync over time | `update`, `audit`, Context Guard hooks + autonomous agent | Manual review after every change | Start from scratch each time |
| Enforces quality standards | 0–100 health score, CI integration, line budgets | No enforcement | No enforcement |
| Handles line budgets | Automatic per-file limits | Easy to exceed without noticing | No awareness of budgets |

---

## 🤖 Commands

ContextDocs provides 3 slash commands covering the full context file lifecycle — generation, freshness enforcement, and quality verification. All commands use the `contextdocs:` prefix when installed as a plugin.

| Command | What It Does | Why It Matters |
|---------|-------------|----------------|
| `/contextdocs:ai-context` | Generate AGENTS-first AI context using Signal Gate — `init`, `update`, `promote`, `audit`, or per-tool (`claude`, `agents`, `cursor`, etc.) | Every AI tool gets lean, accurate project context |
| `/contextdocs:context-guard` | Install, uninstall, or check status of Context Guard hooks *(Claude Code only)* | Stale context files get caught before they waste tokens |
| `/contextdocs:context-verify` | Score context file health 0–100 — line budgets, stale paths, bridge consistency, signal quality | Drift never reaches your team — enforce in CI or check locally |

### Quick Examples

```bash
/contextdocs:ai-context init          # Bootstrap context for a new project
/contextdocs:ai-context update        # Patch only what drifted
/contextdocs:ai-context promote       # Move MEMORY.md patterns to CLAUDE.md
/contextdocs:ai-context audit         # Check for staleness and drift
/contextdocs:context-verify           # Score context file health (0–100)
/contextdocs:context-guard install    # Install freshness hooks
/contextdocs:context-guard status     # Check which hooks are active
```

---

## 🔀 Use with Other AI Tools

ContextDocs generates plain Markdown files placed where each AI tool expects them. `AGENTS.md` is the canonical shared context; bridge files exist only where a tool still benefits from or requires its own file. No manual copying required for any supported tool.

ContextDocs works natively with [Claude Code](https://code.claude.com/) and [OpenCode](https://opencode.ai/). The generated context files are plain Markdown — each is placed where the target tool expects it:

| File | Role | Tool | Automatically Discovered |
|------|------|------|-------------------------|
| AGENTS.md | Canonical shared context | Codex CLI, OpenCode, Gemini CLI, AGENTS-aware tools | Yes — read on startup |
| CLAUDE.md | Thin bridge | Claude Code, OpenCode | Yes — loaded every session |
| .cursorrules | Thin bridge | Cursor | Yes — project root convention |
| .github/copilot-instructions.md | Thin bridge | GitHub Copilot | Yes — GitHub convention |
| .windsurfrules | Compatibility bridge | Windsurf | Yes — project root convention |
| .clinerules | Thin bridge | Cline | Yes — project root convention |
| GEMINI.md | Compatibility bridge | Gemini CLI | Yes — loaded on startup |

Context Guard hooks are Claude Code only. All other features (generation, update, verify) work wherever the plugin runs.

---

## 📚 Documentation

- [Getting Started Guide](docs/guides/getting-started.md) — Installation, first context file generation, and Context Guard setup
- [Troubleshooting](docs/guides/troubleshooting.md) — Signal Gate issues, hook problems, content filter errors, and FAQ
- [Documentation Hub](docs/README.md) — All guides and reference links
- [Support](SUPPORT.md) — Getting help and common questions
- [Security](SECURITY.md) — Vulnerability reporting and response timeline

---

## 🔗 Related

For public-facing repository documentation (README, CHANGELOG, ROADMAP, user guides, launch artifacts), see [PitchDocs](https://github.com/littlebearapps/pitchdocs).

---

## 🤝 Contributing

Found a way to make generated context files even better? We'd love your help — whether it's improving Signal Gate filtering, fixing a hook script, or adding support for a new AI tool's context format.

See our [Contributing Guide](CONTRIBUTING.md) to get started. This project follows the [Contributor Covenant v3.0](CODE_OF_CONDUCT.md).

- [Open Issues](https://github.com/littlebearapps/contextdocs/issues) — See what needs doing
- [Feature Requests](https://github.com/littlebearapps/contextdocs/issues/new) — Suggest improvements

---

## 📄 Licence

[MIT](LICENSE) — Made by [Little Bear Apps](https://littlebearapps.com) 🐶
