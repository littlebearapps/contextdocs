# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| 1.x     | :white_check_mark: |
| < 1.0   | :x: |

## Scope

This is a Claude Code plugin consisting of Markdown files and shell scripts (hooks). It contains no compiled code, no npm/pip dependencies, and processes no user data directly. The security surface is limited to hook scripts that check git status and file timestamps, and generated context files that may contain project-specific paths.

## Reporting a Concern

If you find a security issue (e.g., a hook script vulnerability, a context file template that encourages unsafe patterns, or an information leak risk):

- [Open an issue](https://github.com/littlebearapps/contextdocs/issues/new)
- Or email: hello@littlebearapps.com

We aim to acknowledge reports within 48 hours and provide a resolution or update within 7 days.

## Upstream Specifications

This plugin references the AGENTS.md specification and tracks Claude Code releases. If an upstream spec or platform change introduces a security-relevant change, the monthly (AGENTS.md spec) and weekly (Claude Code releases) [upstream drift check](.github/workflows/check-upstream.yml) will detect it and open an issue for review.
