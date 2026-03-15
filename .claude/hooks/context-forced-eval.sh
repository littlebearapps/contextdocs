#!/bin/bash
# context-forced-eval.sh
# Hook: UserPromptSubmit
# Purpose: Inject skill evaluation context when user prompt matches context-related keywords
# Installed by: /contextdocs:context-guard install
#
# Keyword-gated — only fires on context-related prompts to avoid overhead on
# unrelated coding tasks. Advisory only — never blocks.
#
# Claude Code only — OpenCode, Codex CLI, Cursor, and other tools
# do not support Claude Code hooks.

set -euo pipefail

# Read hook input from stdin
INPUT=$(cat)

# Skip in Untether sessions (Telegram stays lean)
[ -n "${UNTETHER_SESSION:-}" ] && echo '{}' && exit 0

# Extract prompt
PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty' 2>/dev/null || true)

# Skip empty prompts
[ -z "$PROMPT" ] && echo '{}' && exit 0

# Convert to lowercase for matching
LOWER=$(echo "$PROMPT" | tr '[:upper:]' '[:lower:]')

# Check for context-related keywords
MATCH=false

# Slash commands (exact prefix match)
case "$LOWER" in
  /ai-context*|/context-guard*|/context-verify*) MATCH=true ;;
esac

# Keyword matching
if [ "$MATCH" = "false" ]; then
  if echo "$LOWER" | grep -qE '(claude\.md|agents\.md|context|stale|hook[s ]|guard|verify|score|health|cursorrules|copilot|memory.*promot|drift|bridge|ai-context|context-guard|context-verify|llms\.txt|windsurfrules|clinerules|gemini\.md)'; then
    MATCH=true
  fi
fi

# No match — pass through silently
if [ "$MATCH" = "false" ]; then
  echo '{}'
  exit 0
fi

# Inject skill evaluation context
cat << 'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": "SKILL EVALUATION: This project uses ContextDocs (3 skills). Evaluate whether this prompt matches a skill and activate it via the Skill() tool before responding:\n\n1. ai-context — Generate, update, fix, or audit AI IDE context files (CLAUDE.md, AGENTS.md, bridges). Use for stale context, bootstrapping, MEMORY.md promotion, or drift.\n2. context-guard — Install, uninstall, or check Context Guard hooks. Use for hook setup, commit guards, or freshness enforcement.\n3. context-verify — Validate context file quality with 0-100 scoring. Use for health checks, line budgets, CI verification.\n\nIf a skill matches, call Skill(skill-name) NOW. If none match, proceed normally."
  }
}
EOF
