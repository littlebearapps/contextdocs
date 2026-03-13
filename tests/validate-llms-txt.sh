#!/usr/bin/env bash
# Validate llms.txt — check that all referenced file paths actually exist
# and that all plugin component files are referenced (orphan detection).
set -euo pipefail

errors=0
warnings=0

echo "=== Validating llms.txt file references ==="

llms_paths=()
while IFS= read -r path; do
  [ -z "$path" ] && continue
  llms_paths+=("$path")
done < <(python3 - <<'PY'
import re
from pathlib import Path

text = Path('llms.txt').read_text(encoding='utf-8')
for path in re.findall(r'\]\(\./([^)]+)\)', text):
    if path.startswith(('http', 'mailto:')):
        continue
    print(path)
PY
)

for path in "${llms_paths[@]}"; do
  if [ ! -f "$path" ]; then
    echo "ERROR: llms.txt references '$path' but file does not exist"
    errors=$((errors + 1))
  fi
done

echo "File reference check complete"

echo ""
echo "=== Checking for orphaned files ==="

llms_content=$(sed 's|\./||g' llms.txt)

for f in .claude/skills/*/SKILL.md; do
  [ -f "$f" ] || continue
  if ! printf '%s\n' "$llms_content" | grep -qF "$f"; then
    echo "WARNING: $f not referenced in llms.txt"
    warnings=$((warnings + 1))
  fi
done

for f in .claude/skills/*/SKILL-*.md; do
  [ -f "$f" ] || continue
  if ! printf '%s\n' "$llms_content" | grep -qF "$f"; then
    echo "WARNING: $f not referenced in llms.txt"
    warnings=$((warnings + 1))
  fi
done

for f in commands/*.md; do
  [ -f "$f" ] || continue
  if ! printf '%s\n' "$llms_content" | grep -qF "$f"; then
    echo "WARNING: $f not referenced in llms.txt"
    warnings=$((warnings + 1))
  fi
done

if [ -d ".claude/agents" ]; then
  for f in .claude/agents/*.md; do
    [ -f "$f" ] || continue
    if ! printf '%s\n' "$llms_content" | grep -qF "$f"; then
      echo "WARNING: $f not referenced in llms.txt"
      warnings=$((warnings + 1))
    fi
  done
fi

for f in .claude/rules/*.md; do
  [ -f "$f" ] || continue
  if ! printf '%s\n' "$llms_content" | grep -qF "$f"; then
    echo "WARNING: $f not referenced in llms.txt"
    warnings=$((warnings + 1))
  fi
done

for f in hooks/*.sh; do
  [ -f "$f" ] || continue
  if ! printf '%s\n' "$llms_content" | grep -qF "$f"; then
    echo "WARNING: $f not referenced in llms.txt"
    warnings=$((warnings + 1))
  fi
done

echo "Orphan check complete"

if [ -f "AGENTS.md" ]; then
  echo ""
  echo "=== Checking AGENTS.md references ==="
  agents_content=$(sed 's|\./||g' AGENTS.md)

  for f in .claude/skills/*/SKILL.md; do
    [ -f "$f" ] || continue
    skill_name=$(basename "$(dirname "$f")")
    if ! printf '%s\n' "$agents_content" | grep -qi "$skill_name"; then
      echo "WARNING: skill '$skill_name' not referenced in AGENTS.md"
      warnings=$((warnings + 1))
    fi
  done

  for f in commands/*.md; do
    [ -f "$f" ] || continue
    cmd_name=$(basename "$f" .md)
    if ! printf '%s\n' "$agents_content" | grep -qi "$cmd_name"; then
      echo "WARNING: command '$cmd_name' not referenced in AGENTS.md"
      warnings=$((warnings + 1))
    fi
  done

  echo "AGENTS.md check complete"
fi

echo ""
echo "=== Summary ==="
echo "Errors: $errors"
echo "Warnings: $warnings"

if [ "$errors" -gt 0 ]; then
  exit 1
fi

if [ "$warnings" -gt 0 ]; then
  echo "Warnings found — review orphaned files"
fi
