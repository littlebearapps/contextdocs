#!/bin/bash
# update-installed-hooks.sh
# Updates Context Guard hook installations across all projects.
# Idempotent — safe to re-run.
#
# Usage: bash scripts/update-installed-hooks.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source locations
HOOKS_SRC="$SOURCE_DIR/hooks"
AGENT_SRC="$SOURCE_DIR/.claude/agents/context-updater.md"
RULE_SRC="$SOURCE_DIR/.claude/rules/context-quality.md"

# Tier 1 hooks (installed everywhere)
TIER1_HOOKS=(
  "content-filter-guard.sh"
  "context-drift-check.sh"
  "context-structural-change.sh"
  "context-guard-stop.sh"
  "context-session-start.sh"
)

# Tier 2 hook (only updated if already present)
TIER2_HOOK="context-commit-guard.sh"

# Projects to update
PROJECTS=(
  "/home/nathan/claude-code-tools/lba/infrastructure/platform/main"
  "/home/nathan/claude-code-tools/lba/tools/auditor-toolkit/main"
  "/home/nathan/claude-code-tools/lba/marketing/brand-copilot/main"
  "/home/nathan/claude-code-tools/lba/apps/mcp-servers/outlook-assistant/main"
  "/home/nathan/claude-code-tools/lba/apps/ai-plugins/pitchdocs"
  "/home/nathan/claude-code-tools/lba/apps/ai-plugins/contextdocs"
  "/home/nathan/claude-code-tools/lba/factory/triage/main"
  "/home/nathan/claude-code-tools/lba/scout"
)

# SessionStart entry to inject via jq
SESSION_START_ENTRY='{
  "matcher": "",
  "hooks": [
    {
      "type": "command",
      "command": ".claude/hooks/context-session-start.sh"
    }
  ]
}'

UPDATED=0
SKIPPED=0
WARNINGS=()

for PROJECT in "${PROJECTS[@]}"; do
  NAME="${PROJECT##*/claude-code-tools/}"
  echo ""
  echo "=== $NAME ==="

  if [ ! -d "$PROJECT" ]; then
    echo "  SKIP: directory does not exist"
    SKIPPED=$((SKIPPED + 1))
    continue
  fi

  HOOKS_DST="$PROJECT/.claude/hooks"
  AGENTS_DST="$PROJECT/.claude/agents"
  RULES_DST="$PROJECT/.claude/rules"
  SETTINGS="$PROJECT/.claude/settings.json"

  # Ensure target directories exist
  mkdir -p "$HOOKS_DST" "$AGENTS_DST" "$RULES_DST"

  # Skip self-copy when source and target are the same project
  IS_SELF="false"
  [ "$(realpath "$PROJECT")" = "$(realpath "$SOURCE_DIR")" ] && IS_SELF="true"

  # --- Copy Tier 1 hooks ---
  for HOOK in "${TIER1_HOOKS[@]}"; do
    if [ "$IS_SELF" = "true" ]; then
      # Source hooks/ → .claude/hooks/ within same project
      if [ "$(realpath "$HOOKS_SRC/$HOOK")" != "$(realpath "$HOOKS_DST/$HOOK")" ]; then
        cp "$HOOKS_SRC/$HOOK" "$HOOKS_DST/$HOOK"
      fi
    else
      cp "$HOOKS_SRC/$HOOK" "$HOOKS_DST/$HOOK"
    fi
    chmod +x "$HOOKS_DST/$HOOK"
    echo "  hook: $HOOK"
  done

  # --- Copy Tier 2 hook if already installed ---
  if [ -f "$HOOKS_DST/$TIER2_HOOK" ]; then
    if [ "$IS_SELF" = "true" ]; then
      if [ "$(realpath "$HOOKS_SRC/$TIER2_HOOK")" != "$(realpath "$HOOKS_DST/$TIER2_HOOK")" ]; then
        cp "$HOOKS_SRC/$TIER2_HOOK" "$HOOKS_DST/$TIER2_HOOK"
      fi
    else
      cp "$HOOKS_SRC/$TIER2_HOOK" "$HOOKS_DST/$TIER2_HOOK"
    fi
    chmod +x "$HOOKS_DST/$TIER2_HOOK"
    echo "  hook: $TIER2_HOOK (Tier 2)"
  fi

  # --- Copy agent ---
  if [ "$IS_SELF" != "true" ] || [ "$(realpath "$AGENT_SRC")" != "$(realpath "$AGENTS_DST/context-updater.md")" ]; then
    cp "$AGENT_SRC" "$AGENTS_DST/context-updater.md"
  fi
  echo "  agent: context-updater.md"

  # --- Copy rule ---
  if [ "$IS_SELF" != "true" ] || [ "$(realpath "$RULE_SRC")" != "$(realpath "$RULES_DST/context-quality.md")" ]; then
    cp "$RULE_SRC" "$RULES_DST/context-quality.md"
  fi
  echo "  rule: context-quality.md"

  # --- Patch settings.json: add SessionStart if missing ---
  if [ -f "$SETTINGS" ]; then
    # Check if SessionStart already has the context-session-start hook
    HAS_SESSION_START=$(jq '
      .hooks.SessionStart // [] |
      any(.[]; .hooks[]?.command | test("context-session-start\\.sh"))
    ' "$SETTINGS" 2>/dev/null || echo "false")

    if [ "$HAS_SESSION_START" = "true" ]; then
      echo "  settings.json: SessionStart already present"
    else
      # Add SessionStart entry — append to existing array or create it
      TEMP=$(mktemp)
      jq --argjson entry "$SESSION_START_ENTRY" '
        .hooks.SessionStart = (.hooks.SessionStart // []) + [$entry]
      ' "$SETTINGS" > "$TEMP" && mv "$TEMP" "$SETTINGS"
      echo "  settings.json: added SessionStart entry"
    fi

    # --- Warn if Stop hook entry is missing from settings.json ---
    HAS_STOP=$(jq '
      .hooks.Stop // [] |
      any(.[]; .hooks[]?.command | test("context-guard-stop\\.sh"))
    ' "$SETTINGS" 2>/dev/null || echo "false")

    if [ "$HAS_STOP" != "true" ]; then
      WARNINGS+=("$NAME: Stop hook entry missing from settings.json (context-guard-stop.sh won't run)")
    fi
  else
    echo "  settings.json: NOT FOUND — skipping patch"
    WARNINGS+=("$NAME: no .claude/settings.json found")
  fi

  UPDATED=$((UPDATED + 1))
done

echo ""
echo "--- Summary ---"
echo "Updated: $UPDATED projects"
echo "Skipped: $SKIPPED projects"

if [ ${#WARNINGS[@]} -gt 0 ]; then
  echo ""
  echo "Warnings:"
  for W in "${WARNINGS[@]}"; do
    echo "  ! $W"
  done
fi

echo ""
echo "Done. Verify with:"
echo "  diff <project>/.claude/hooks/context-guard-stop.sh hooks/context-guard-stop.sh"
echo "  jq '.hooks.SessionStart' <project>/.claude/settings.json"
