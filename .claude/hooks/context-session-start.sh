#!/bin/bash
# context-session-start.sh
# Hook: SessionStart
# Purpose: Quick context health check at session start
# Installed by: /contextdocs:context-guard install
#
# Claude Code only — OpenCode, Codex CLI, Cursor, and other tools
# do not support Claude Code hooks.

set -euo pipefail

# Read hook input from stdin
INPUT=$(cat)

# Resolve project directory
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
cd "$PROJECT_DIR" || { echo '{}'; exit 0; }

# Must be inside a git repository
git rev-parse --is-inside-work-tree &>/dev/null || { echo '{}'; exit 0; }

# Context files to check
CONTEXT_FILES=("CLAUDE.md" "AGENTS.md" "GEMINI.md" ".cursorrules"
               ".github/copilot-instructions.md" "llms.txt" ".windsurfrules" ".clinerules")

FOUND=()
STALE=()
TOTAL_LINES=0

for CTX in "${CONTEXT_FILES[@]}"; do
  [ ! -f "$CTX" ] && continue
  FOUND+=("$CTX")

  # Count lines for aggregate budget
  LINES=$(wc -l < "$CTX" 2>/dev/null || echo "0")
  TOTAL_LINES=$((TOTAL_LINES + LINES))

  # Check staleness: context file older than most recent source commit
  CTX_COMMIT_TIME=$(git log -1 --format=%ct -- "$CTX" 2>/dev/null || echo "0")
  SRC_COMMIT_TIME=$(git log -1 --format=%ct -- \
    '*.ts' '*.js' '*.py' '*.go' '*.rs' '*.json' '*.toml' '*.yaml' '*.yml' \
    ':!*.md' ':!CHANGELOG.md' ':!README.md' ':!docs/*' 2>/dev/null || echo "0")

  if [ "$SRC_COMMIT_TIME" -gt "$CTX_COMMIT_TIME" ] 2>/dev/null; then
    COMMITS_BEHIND=$(git rev-list --count "$(git log -1 --format=%H -- "$CTX" 2>/dev/null || echo HEAD)"..HEAD -- \
      '*.ts' '*.js' '*.py' '*.go' '*.rs' '*.json' '*.toml' '*.yaml' '*.yml' \
      ':!*.md' 2>/dev/null || echo "?")
    STALE+=("$CTX ($COMMITS_BEHIND source commits behind)")
  fi
done

# No context files at all — nothing to report
[ ${#FOUND[@]} -eq 0 ] && echo '{}' && exit 0

# Build issues list
ISSUES=()

# Check for stale files
for S in "${STALE[@]}"; do
  ISSUES+=("  - Stale: $S")
done

# Warn if aggregate lines are high (rough budget: 300 lines across all files)
if [ "$TOTAL_LINES" -gt 300 ]; then
  ISSUES+=("  - Aggregate context: ${TOTAL_LINES} lines across ${#FOUND[@]} files (consider trimming)")
fi

if [ ${#ISSUES[@]} -gt 0 ]; then
  MSG="CONTEXT HEALTH CHECK (${#FOUND[@]} context files found):"
  for I in "${ISSUES[@]}"; do
    MSG="$MSG\n$I"
  done
  MSG="$MSG\nRun /contextdocs:context-verify for a full health score."

  MSG_JSON=$(printf '%s' "$MSG" | sed 's/"/\\"/g')

  cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "$MSG_JSON"
  }
}
EOF
else
  echo '{}'
fi
