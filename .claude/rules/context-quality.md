# AI Context File Quality Standards

When generating or updating AI context files (CLAUDE.md, AGENTS.md, GEMINI.md, .cursorrules, copilot-instructions.md, .windsurfrules, .clinerules), follow these standards.

## Cross-File Consistency

All context files must agree on: language/framework version, key commands (test, build, lint, deploy), directory structure, naming conventions, and critical rules. When updating one, check and update others.

## Path and Command Verification

Every file path in a context file must exist on disk. Every command must be runnable — verify against `package.json` scripts, `Makefile` targets, or `pyproject.toml` scripts before writing.

## Version Accuracy

Reference correct language runtime (from `.nvmrc`, `engines`, `requires-python`, `go.mod`), framework version (from manifests), test runner, and linter/formatter.

## Sync Points

When project structure, dependencies, commands, or conventions change, update all context files that reference the affected content. Load the `ai-context` skill for the full sync matrix.

## Tool Compatibility

`AGENTS.md`: Claude Code, OpenCode, Codex CLI, Gemini CLI. `CLAUDE.md`: Claude Code, OpenCode. `.cursorrules`, `.windsurfrules`, `.clinerules`, `GEMINI.md`, `copilot-instructions.md`: tool-specific. `.claude/rules/*.md` and hooks: Claude Code only. `MEMORY.md`: auto-written by Claude, not version-controlled.

## Aggregate Context Load

Thresholds per tool: <5,000 tokens healthy, 5,000–10,000 warning, >10,000 needs refactoring. Use `context-verify` to check. See context-verify skill for per-tool load paths and detailed reporting.
