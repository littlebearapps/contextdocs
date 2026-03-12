#!/bin/bash
# test-hooks.sh
# Unit tests for all 6 ContextDocs hooks.
# Exit 0 = all pass, Exit 1 = failures found

set -euo pipefail

PASS=0
FAIL=0
TOTAL=0

# --- Test harness for pure hooks (stdin JSON → stdout JSON + exit code) ---
run_test() {
  local desc="$1"
  local hook="$2"
  local input="$3"
  local expect_exit="$4"
  local expect_grep="${5:-}"

  TOTAL=$((TOTAL + 1))
  local output exit_code
  output=$(echo "$input" | bash "$hook" 2>&1) || true
  exit_code=$(echo "$input" | bash "$hook" >/dev/null 2>&1; echo $?) || true

  local passed=true
  if [ "$exit_code" -ne "$expect_exit" ]; then
    passed=false
  fi
  if [ -n "$expect_grep" ] && ! echo "$output" | grep -q "$expect_grep"; then
    passed=false
  fi

  if $passed; then
    PASS=$((PASS + 1))
    echo "  PASS: $desc"
  else
    FAIL=$((FAIL + 1))
    echo "  FAIL: $desc (exit=$exit_code, expected=$expect_exit)"
    echo "        output: $(echo "$output" | head -1)"
  fi
}

# --- Git-dependent test harness ---
TEMP_REPO=""

setup_git_repo() {
  TEMP_REPO=$(mktemp -d)
  cd "$TEMP_REPO"
  git init -q
  git config user.email "test@test.com"
  git config user.name "Test"
  echo "init" > init.txt
  git add init.txt
  git commit -q -m "initial"
  export CLAUDE_PROJECT_DIR="$TEMP_REPO"
}

teardown_git_repo() {
  cd /
  [ -n "$TEMP_REPO" ] && rm -rf "$TEMP_REPO"
  unset CLAUDE_PROJECT_DIR
  TEMP_REPO=""
}

# Save original dir
ORIG_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "=== Hook Unit Tests: ContextDocs ==="
echo ""

########################################################################
# SECTION 1: content-filter-guard.sh
########################################################################
HOOK="$ORIG_DIR/hooks/content-filter-guard.sh"
echo "--- Section 1: content-filter-guard.sh ---"
echo ""
echo "--- HIGH-risk files (should block, exit 1) ---"

run_test "CODE_OF_CONDUCT.md blocks" "$HOOK" \
  '{"tool_name":"Write","tool_input":{"file_path":"CODE_OF_CONDUCT.md"}}' 1 "block"
run_test "CODE_OF_CONDUCT.MD blocks" "$HOOK" \
  '{"tool_name":"Write","tool_input":{"file_path":"CODE_OF_CONDUCT.MD"}}' 1 "block"
run_test "LICENSE blocks" "$HOOK" \
  '{"tool_name":"Write","tool_input":{"file_path":"LICENSE"}}' 1 "block"
run_test "LICENSE.md blocks" "$HOOK" \
  '{"tool_name":"Write","tool_input":{"file_path":"LICENSE.md"}}' 1 "block"
run_test "LICENSE.txt blocks" "$HOOK" \
  '{"tool_name":"Write","tool_input":{"file_path":"LICENSE.txt"}}' 1 "block"
run_test "LICENCE blocks (AU spelling)" "$HOOK" \
  '{"tool_name":"Write","tool_input":{"file_path":"LICENCE"}}' 1 "block"
run_test "LICENCE.md blocks" "$HOOK" \
  '{"tool_name":"Write","tool_input":{"file_path":"LICENCE.md"}}' 1 "block"
run_test "LICENCE.txt blocks" "$HOOK" \
  '{"tool_name":"Write","tool_input":{"file_path":"LICENCE.txt"}}' 1 "block"
run_test "SECURITY.md blocks" "$HOOK" \
  '{"tool_name":"Write","tool_input":{"file_path":"SECURITY.md"}}' 1 "block"
run_test "SECURITY.MD blocks" "$HOOK" \
  '{"tool_name":"Write","tool_input":{"file_path":"SECURITY.MD"}}' 1 "block"
run_test "Nested path CODE_OF_CONDUCT" "$HOOK" \
  '{"tool_name":"Write","tool_input":{"file_path":"/tmp/project/CODE_OF_CONDUCT.md"}}' 1 "block"
run_test "Nested path LICENSE" "$HOOK" \
  '{"tool_name":"Write","tool_input":{"file_path":"src/LICENSE.md"}}' 1 "block"

echo ""
echo "--- MEDIUM-risk files (should allow with advisory, exit 0) ---"
run_test "CHANGELOG.md advisory" "$HOOK" \
  '{"tool_name":"Write","tool_input":{"file_path":"CHANGELOG.md"}}' 0 "CONTENT FILTER ADVISORY"
run_test "CHANGELOG.MD advisory" "$HOOK" \
  '{"tool_name":"Write","tool_input":{"file_path":"CHANGELOG.MD"}}' 0 "CONTENT FILTER ADVISORY"
run_test "CONTRIBUTING.md advisory" "$HOOK" \
  '{"tool_name":"Write","tool_input":{"file_path":"CONTRIBUTING.md"}}' 0 "CONTENT FILTER ADVISORY"
run_test "CONTRIBUTING.MD advisory" "$HOOK" \
  '{"tool_name":"Write","tool_input":{"file_path":"CONTRIBUTING.MD"}}' 0 "CONTENT FILTER ADVISORY"

echo ""
echo "--- Safe files (should pass through, exit 0) ---"
run_test "README.md passes" "$HOOK" \
  '{"tool_name":"Write","tool_input":{"file_path":"README.md"}}' 0 "{}"
run_test "src/index.ts passes" "$HOOK" \
  '{"tool_name":"Write","tool_input":{"file_path":"src/index.ts"}}' 0 "{}"
run_test "package.json passes" "$HOOK" \
  '{"tool_name":"Write","tool_input":{"file_path":"package.json"}}' 0 "{}"

echo ""
echo "--- Non-Write tools (should pass through, exit 0) ---"
run_test "Read tool passes" "$HOOK" \
  '{"tool_name":"Read","tool_input":{"file_path":"CODE_OF_CONDUCT.md"}}' 0 "{}"
run_test "Edit tool passes" "$HOOK" \
  '{"tool_name":"Edit","tool_input":{"file_path":"CODE_OF_CONDUCT.md"}}' 0 "{}"
run_test "Bash tool passes" "$HOOK" \
  '{"tool_name":"Bash","tool_input":{"command":"cat CODE_OF_CONDUCT.md"}}' 0 "{}"

echo ""
echo "--- Edge cases (should pass through, exit 0) ---"
run_test "Empty JSON" "$HOOK" '{}' 0 "{}"
run_test "Missing file_path" "$HOOK" '{"tool_name":"Write","tool_input":{}}' 0 "{}"
run_test "Missing tool_input" "$HOOK" '{"tool_name":"Write"}' 0 "{}"

echo ""

########################################################################
# SECTION 2: context-structural-change.sh
########################################################################
HOOK="$ORIG_DIR/hooks/context-structural-change.sh"
echo "--- Section 2: context-structural-change.sh ---"
echo ""

# Setup: temp dir with CLAUDE.md so the hook has context files to check
STRUCT_TEMP=$(mktemp -d)
touch "$STRUCT_TEMP/CLAUDE.md"
export CLAUDE_PROJECT_DIR="$STRUCT_TEMP"

echo "--- Commands match (exit 0 with advisory) ---"
run_test "commands/foo.md triggers reminder" "$HOOK" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$STRUCT_TEMP/commands/foo.md\"}}" 0 "CONTEXT REMINDER"
run_test "commands/nested/bar.md triggers reminder" "$HOOK" \
  "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$STRUCT_TEMP/commands/nested/bar.md\"}}" 0 "CONTEXT REMINDER"

echo ""
echo "--- Skills match (exit 0 with advisory) ---"
run_test ".claude/skills/foo/SKILL.md triggers reminder" "$HOOK" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$STRUCT_TEMP/.claude/skills/foo/SKILL.md\"}}" 0 "CONTEXT REMINDER"
run_test ".agents/skills/foo/SKILL.md triggers reminder" "$HOOK" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$STRUCT_TEMP/.agents/skills/foo/SKILL.md\"}}" 0 "CONTEXT REMINDER"

echo ""
echo "--- Agents match (exit 0 with advisory) ---"
run_test ".claude/agents/foo.md triggers reminder" "$HOOK" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$STRUCT_TEMP/.claude/agents/foo.md\"}}" 0 "CONTEXT REMINDER"

echo ""
echo "--- Rules match (exit 0 with advisory) ---"
run_test ".claude/rules/naming.md triggers reminder" "$HOOK" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$STRUCT_TEMP/.claude/rules/naming.md\"}}" 0 "CONTEXT REMINDER"

echo ""
echo "--- Rules excluded (context-quality.md, exit 0 silent) ---"
run_test ".claude/rules/context-quality.md excluded" "$HOOK" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$STRUCT_TEMP/.claude/rules/context-quality.md\"}}" 0 "{}"

echo ""
echo "--- Config files (exit 0 with advisory) ---"
run_test "package.json triggers reminder" "$HOOK" \
  "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$STRUCT_TEMP/package.json\"}}" 0 "CONTEXT REMINDER"
run_test "wrangler.toml triggers reminder" "$HOOK" \
  "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$STRUCT_TEMP/wrangler.toml\"}}" 0 "CONTEXT REMINDER"
run_test "biome.json triggers reminder" "$HOOK" \
  "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$STRUCT_TEMP/biome.json\"}}" 0 "CONTEXT REMINDER"

echo ""
echo "--- Safe files (exit 0 silent) ---"
run_test "src/index.ts silent" "$HOOK" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$STRUCT_TEMP/src/index.ts\"}}" 0 "{}"

echo ""
echo "--- Non-Write/Edit tool (exit 0 silent) ---"
run_test "Read tool silent" "$HOOK" \
  '{"tool_name":"Read","tool_input":{"file_path":"commands/foo.md"}}' 0 "{}"

echo ""
echo "--- No context files on disk (exit 0 silent) ---"
NO_CTX_TEMP=$(mktemp -d)
export CLAUDE_PROJECT_DIR="$NO_CTX_TEMP"
run_test "No context files → silent" "$HOOK" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$NO_CTX_TEMP/commands/foo.md\"}}" 0 "{}"
rm -rf "$NO_CTX_TEMP"

# Restore for next section
export CLAUDE_PROJECT_DIR="$STRUCT_TEMP"
rm -rf "$STRUCT_TEMP"
unset CLAUDE_PROJECT_DIR

echo ""

########################################################################
# SECTION 3: context-commit-guard.sh
########################################################################
HOOK="$ORIG_DIR/hooks/context-commit-guard.sh"
echo "--- Section 3: context-commit-guard.sh ---"
echo ""

echo "--- Structural staged, no context → BLOCK (exit 2) ---"

# Test: commands/foo.md staged without context file
setup_git_repo
mkdir -p commands
echo "test" > commands/foo.md
git add commands/foo.md
run_test "commands/foo.md staged without context → block" "$HOOK" \
  '{"tool_name":"Bash","tool_input":{"command":"git commit -m test"}}' 2 "COMMIT BLOCKED"
teardown_git_repo

# Test: package.json staged without context file
setup_git_repo
echo '{}' > package.json
git add package.json
run_test "package.json staged without context → block" "$HOOK" \
  '{"tool_name":"Bash","tool_input":{"command":"git commit -m test"}}' 2 "COMMIT BLOCKED"
teardown_git_repo

# Test: .claude/skills/x/SKILL.md staged without context file
setup_git_repo
mkdir -p .claude/skills/x
echo "test" > .claude/skills/x/SKILL.md
git add .claude/skills/x/SKILL.md
run_test ".claude/skills/x/SKILL.md staged without context → block" "$HOOK" \
  '{"tool_name":"Bash","tool_input":{"command":"git commit -m test"}}' 2 "COMMIT BLOCKED"
teardown_git_repo

echo ""
echo "--- Structural staged + context staged → ALLOW (exit 0) ---"

# Test: structural + CLAUDE.md staged
setup_git_repo
mkdir -p commands
echo "test" > commands/foo.md
echo "ctx" > CLAUDE.md
git add commands/foo.md CLAUDE.md
run_test "commands/foo.md + CLAUDE.md staged → allow" "$HOOK" \
  '{"tool_name":"Bash","tool_input":{"command":"git commit -m test"}}' 0
teardown_git_repo

# Test: structural + AGENTS.md staged
setup_git_repo
mkdir -p commands
echo "test" > commands/foo.md
echo "ctx" > AGENTS.md
git add commands/foo.md AGENTS.md
run_test "commands/foo.md + AGENTS.md staged → allow" "$HOOK" \
  '{"tool_name":"Bash","tool_input":{"command":"git commit -m test"}}' 0
teardown_git_repo

# Test: structural + llms.txt staged
setup_git_repo
mkdir -p commands
echo "test" > commands/foo.md
echo "ctx" > llms.txt
git add commands/foo.md llms.txt
run_test "commands/foo.md + llms.txt staged → allow" "$HOOK" \
  '{"tool_name":"Bash","tool_input":{"command":"git commit -m test"}}' 0
teardown_git_repo

echo ""
echo "--- Non-structural staged → ALLOW (exit 0) ---"
setup_git_repo
echo "code" > app.ts
git add app.ts
run_test "src/app.ts staged → allow" "$HOOK" \
  '{"tool_name":"Bash","tool_input":{"command":"git commit -m test"}}' 0
teardown_git_repo

echo ""
echo "--- No staged files → ALLOW (exit 0) ---"
setup_git_repo
run_test "No staged files → allow" "$HOOK" \
  '{"tool_name":"Bash","tool_input":{"command":"git commit -m test"}}' 0
teardown_git_repo

echo ""
echo "--- Excluded patterns → ALLOW (exit 0) ---"
setup_git_repo
mkdir -p .claude/hooks
echo "test" > .claude/hooks/foo.sh
git add .claude/hooks/foo.sh
run_test ".claude/hooks/foo.sh excluded → allow" "$HOOK" \
  '{"tool_name":"Bash","tool_input":{"command":"git commit -m test"}}' 0
teardown_git_repo

setup_git_repo
mkdir -p .claude/rules
echo "test" > .claude/rules/context-quality.md
git add .claude/rules/context-quality.md
run_test ".claude/rules/context-quality.md excluded → allow" "$HOOK" \
  '{"tool_name":"Bash","tool_input":{"command":"git commit -m test"}}' 0
teardown_git_repo

echo ""
echo "--- Non-Bash tool → ALLOW (exit 0) ---"
run_test "Non-Bash tool → allow" "$HOOK" \
  '{"tool_name":"Write","tool_input":{"file_path":"test.md"}}' 0 "{}"

echo ""
echo "--- Non-git-commit command → ALLOW (exit 0) ---"
run_test "Non-git-commit command → allow" "$HOOK" \
  '{"tool_name":"Bash","tool_input":{"command":"git status"}}' 0 "{}"

echo ""

########################################################################
# SECTION 4: context-drift-check.sh
########################################################################
HOOK="$ORIG_DIR/hooks/context-drift-check.sh"
echo "--- Section 4: context-drift-check.sh ---"
echo ""

echo "--- Gate logic (exit 0 silent) ---"
run_test "Non-Bash tool → silent" "$HOOK" \
  '{"tool_name":"Write","tool_input":{"file_path":"test.md"}}' 0 "{}"
run_test "Bash with non-commit command → silent" "$HOOK" \
  '{"tool_name":"Bash","tool_input":{"command":"git status"}}' 0 "{}"

# Non-git-repo directory
NONGIT_TEMP=$(mktemp -d)
export CLAUDE_PROJECT_DIR="$NONGIT_TEMP"
run_test "Non-git-repo directory → silent" "$HOOK" \
  '{"tool_name":"Bash","tool_input":{"command":"git commit -m test"}}' 0 "{}"
rm -rf "$NONGIT_TEMP"
unset CLAUDE_PROJECT_DIR

# Throttle file recent
setup_git_repo
echo "$(date +%s)" > "$TEMP_REPO/.git/.context-guard-last-check"
run_test "Throttle file recent (<3600s) → silent" "$HOOK" \
  '{"tool_name":"Bash","tool_input":{"command":"git commit -m test"}}' 0 "{}"
teardown_git_repo

# No context files → silent (nothing to drift-check)
setup_git_repo
# Remove throttle so it proceeds past throttle check, but there are no context files
run_test "No context files → silent" "$HOOK" \
  '{"tool_name":"Bash","tool_input":{"command":"git commit -m test"}}' 0 "{}"
teardown_git_repo

# Context file exists but up to date → silent
setup_git_repo
echo "# Context" > "$TEMP_REPO/CLAUDE.md"
git add CLAUDE.md
git commit -q -m "add context"
run_test "Context file up to date → silent" "$HOOK" \
  '{"tool_name":"Bash","tool_input":{"command":"git commit -m test"}}' 0 "{}"
teardown_git_repo

echo ""

########################################################################
# SECTION 5: context-guard-stop.sh
########################################################################
HOOK="$ORIG_DIR/hooks/context-guard-stop.sh"
echo "--- Section 5: context-guard-stop.sh ---"
echo ""

echo "--- Loop prevention and skip conditions ---"
run_test "stop_hook_active: true → silent" "$HOOK" \
  '{"stop_hook_active":true}' 0 "{}"

# Untether skip
export UNTETHER_SESSION="test"
run_test "UNTETHER_SESSION set → silent" "$HOOK" \
  '{}' 0 "{}"
unset UNTETHER_SESSION

# Non-git-repo
NONGIT_TEMP=$(mktemp -d)
export CLAUDE_PROJECT_DIR="$NONGIT_TEMP"
run_test "Non-git-repo → silent" "$HOOK" \
  '{}' 0 "{}"
rm -rf "$NONGIT_TEMP"
unset CLAUDE_PROJECT_DIR

echo ""
echo "--- Git-dependent stop hook tests ---"

# No changed files → silent
setup_git_repo
run_test "No changed files → silent" "$HOOK" \
  '{}' 0 "{}"
teardown_git_repo

# Structural file modified, no context file → block advisory
# Must be tracked then modified so git status shows "M commands/foo.md"
# (untracked dirs show as "commands/" which won't match the glob pattern)
setup_git_repo
mkdir -p commands
echo "test" > commands/foo.md
git add commands/foo.md
git commit -q -m "add command"
echo "modified" > commands/foo.md
run_test "Structural file modified, no context → block" "$HOOK" \
  '{}' 0 "CONTEXT DRIFT DETECTED"
teardown_git_repo

# Structural file modified + CLAUDE.md modified → silent
setup_git_repo
mkdir -p commands
echo "test" > commands/foo.md
echo "ctx" > CLAUDE.md
run_test "Structural + CLAUDE.md modified → silent" "$HOOK" \
  '{}' 0 "{}"
teardown_git_repo

# Non-structural file modified → silent
setup_git_repo
echo "code" > app.ts
run_test "Non-structural file modified → silent" "$HOOK" \
  '{}' 0 "{}"
teardown_git_repo

# Excluded file modified → silent
setup_git_repo
mkdir -p .claude/hooks
echo "test" > .claude/hooks/foo.sh
run_test "Excluded .claude/hooks/foo.sh → silent" "$HOOK" \
  '{}' 0 "{}"
teardown_git_repo

# package.json structural → block
setup_git_repo
echo '{}' > package.json
run_test "package.json modified, no context → block" "$HOOK" \
  '{}' 0 "CONTEXT DRIFT DETECTED"
teardown_git_repo

echo ""

########################################################################
# 6. context-session-start.sh (SessionStart)
########################################################################
echo "--- context-session-start.sh ---"
HOOK="$ORIG_DIR/.claude/hooks/context-session-start.sh"

# No git repo → silent pass
run_test "No git repo → silent" "$HOOK" \
  '{}' 0 "{}"

# Git repo with no context files → silent
setup_git_repo
run_test "No context files → silent" "$HOOK" \
  '{}' 0 "{}"
teardown_git_repo

# Git repo with up-to-date context file → silent
setup_git_repo
echo "# Context" > CLAUDE.md
git add CLAUDE.md
git commit -q -m "add context"
run_test "Up-to-date CLAUDE.md → silent" "$HOOK" \
  '{}' 0 "{}"
teardown_git_repo

# Git repo with stale context file → reports health check
setup_git_repo
echo "# Context" > CLAUDE.md
git add CLAUDE.md
GIT_COMMITTER_DATE="2025-01-01T00:00:00" git commit -q -m "add context" --date="2025-01-01T00:00:00"
echo "code" > app.js
git add app.js
GIT_COMMITTER_DATE="2025-06-01T00:00:00" git commit -q -m "add code" --date="2025-06-01T00:00:00"
run_test "Stale CLAUDE.md → health check" "$HOOK" \
  '{}' 0 "CONTEXT HEALTH CHECK"
teardown_git_repo

# Large aggregate context → warns about line count
setup_git_repo
for i in $(seq 1 310); do echo "line $i" >> CLAUDE.md; done
git add CLAUDE.md
git commit -q -m "add large context"
run_test "Large aggregate context → warns" "$HOOK" \
  '{}' 0 "Aggregate context"
teardown_git_repo

# Always exits 0 (advisory only)
setup_git_repo
echo "# Context" > CLAUDE.md
git add CLAUDE.md
GIT_COMMITTER_DATE="2025-01-01T00:00:00" git commit -q -m "add context" --date="2025-01-01T00:00:00"
echo "code" > app.ts
git add app.ts
GIT_COMMITTER_DATE="2025-06-01T00:00:00" git commit -q -m "add code" --date="2025-06-01T00:00:00"
run_test "Always exits 0 (advisory)" "$HOOK" \
  '{}' 0
teardown_git_repo

# Valid JSON output when issues found
setup_git_repo
echo "# Context" > CLAUDE.md
git add CLAUDE.md
GIT_COMMITTER_DATE="2025-01-01T00:00:00" git commit -q -m "add context" --date="2025-01-01T00:00:00"
echo "code" > main.py
git add main.py
GIT_COMMITTER_DATE="2025-06-01T00:00:00" git commit -q -m "add code" --date="2025-06-01T00:00:00"
run_test "Valid JSON output with issues" "$HOOK" \
  '{}' 0 "hookSpecificOutput"
teardown_git_repo

echo ""

########################################################################
# SUMMARY
########################################################################
echo "=== Results: $PASS/$TOTAL passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
