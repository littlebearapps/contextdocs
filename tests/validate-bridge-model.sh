#!/usr/bin/env bash
# Validate that the repository consistently documents the AGENTS-first bridge model.
set -euo pipefail

errors=0

check_contains() {
  local file="$1"
  local needle="$2"
  local label="$3"
  if ! grep -qF "$needle" "$file"; then
    echo "ERROR: $file — missing $label"
    errors=$((errors + 1))
  fi
}

echo "=== Validating AGENTS-first bridge model ==="

check_contains "commands/ai-context.md" "AGENTS.md as the canonical shared context" "AGENTS-first command description"
check_contains ".claude/skills/ai-context/SKILL.md" 'Generate `AGENTS.md` first' "AGENTS-first generation workflow"
check_contains ".claude/rules/context-quality.md" "Bridge files may subset that content" "bridge consistency guidance"
check_contains ".claude/skills/context-verify/SKILL.md" "AGENTS-to-Bridge Consistency" "bridge consistency verification section"
check_contains ".claude/agents/context-updater.md" 'Prefer updating `AGENTS.md` first' "AGENTS-first updater rule"
check_contains "README.md" "AGENTS-first generation + thin bridges" "README feature callout"
check_contains "docs/guides/getting-started.md" 'Generate canonical `AGENTS.md`, then add the bridge files each tool needs' "getting-started bridge explanation"
check_contains "hooks/context-guard-stop.sh" "Update AGENTS.md first, then refresh only the affected bridge files" "hook AGENTS-first reminder"

echo "Errors: $errors"
[ "$errors" -eq 0 ]
