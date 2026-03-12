# AI Context File Quality Standards

When generating or updating AI context files, treat `AGENTS.md` as the canonical shared context and keep other files as thin bridges.

## Bridge Consistency

`AGENTS.md` owns shared commands, conventions, naming rules, and security constraints. Bridge files may subset that content when needed, but they must not contradict `AGENTS.md`. If a bridge grows because it repeats shared content, move that material back into `AGENTS.md` and leave only tool-specific instructions.

## Path and Command Verification

Every file path in a context file must exist on disk. Every command must be runnable — verify against `package.json`, `Makefile`, or `pyproject.toml` before writing. If `CLAUDE.md` uses `@AGENTS.md` or other imports, verify those too.

## Version Accuracy

Reference correct language runtime (from `.nvmrc`, `engines`, `requires-python`, `go.mod`), framework version (from manifests), test runner, and linter/formatter.

## Sync Points

When structure, dependencies, commands, or conventions change, update `AGENTS.md` first. Then update only the bridge files that reference that content or add tool-specific notes. When using path-scoped rules (`paths:` frontmatter), verify globs still match after renames or directory changes. Load the `ai-context` skill for the full sync matrix.

## Tool Compatibility

`AGENTS.md`: canonical shared context, read natively by OpenCode, Codex CLI, Gemini CLI, and other AGENTS-aware tools. `CLAUDE.md`: Claude Code/OpenCode bridge that can import `@AGENTS.md`. `.cursorrules`, `.windsurfrules`, `.clinerules`, `GEMINI.md`, `copilot-instructions.md`: thin bridges. `.claude/rules/*.md` and hooks: Claude Code only. `MEMORY.md`: auto-written by Claude, not version-controlled.

## Aggregate Context Load

Thresholds per tool: <5,000 tokens healthy, 5,000–10,000 warning, >10,000 needs refactoring. Use `context-verify` to check. See context-verify skill for per-tool load paths and detailed reporting.
