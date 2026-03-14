#!/bin/bash
# check-version-consistency.sh
# Verifies all version references match the canonical version in plugin.json.
# Catches stale version strings that release-please markers may have missed.

set -euo pipefail

ERRORS=0

# Canonical version from plugin.json
VERSION=$(python3 -c "import json; print(json.load(open('.claude-plugin/plugin.json'))['version'])")
echo "Canonical version: $VERSION"
echo ""

check_file() {
  local file="$1"
  local pattern="$2"
  local description="$3"

  if [ ! -f "$file" ]; then
    return
  fi

  if ! grep -q "$pattern" "$file"; then
    echo "  FAIL: $file — $description"
    ERRORS=$((ERRORS + 1))
  else
    echo "  OK: $file"
  fi
}

echo "=== Version consistency check ==="
echo ""

# Files managed by release-please (verify they were updated)
check_file ".release-please-manifest.json" "\"$VERSION\"" "manifest version mismatch"
check_file "SKILL.md" "version: \"$VERSION\"" "SKILL.md version mismatch"
check_file "README.md" "message=$VERSION" "README badge version mismatch"

# Files with x-release-please-version markers
check_file "llms.txt" "v$VERSION" "llms.txt version reference stale"
check_file "docs/guides/troubleshooting.md" "\"$VERSION\"" "troubleshooting last_verified stale"

# Negative check: version should NOT appear in scripts (we removed it)
if grep -rq "to v[0-9]\+\.[0-9]\+\.[0-9]\+" scripts/ 2>/dev/null; then
  echo "  WARN: scripts/ contains hardcoded version references"
fi

echo ""
echo "=== Summary ==="
if [ "$ERRORS" -eq 0 ]; then
  echo "All version references match $VERSION"
else
  echo "$ERRORS version inconsistencies found"
  exit 1
fi
