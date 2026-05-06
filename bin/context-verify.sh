#!/usr/bin/env bash
# context-verify.sh — Standalone AI context file health scorer
# Works on any platform with bash + git. No plugin system required.
#
# Usage:
#   ./bin/context-verify.sh              # Interactive report
#   ./bin/context-verify.sh --ci         # CI mode (exit 1 on score < 80)
#   ./bin/context-verify.sh --ci --min-score 90  # Custom threshold
#
# Implements 13 of the 16 context-verify checks from ContextDocs.
# Checks 2 (discoverable content) and 4 (AGENTS-to-bridge consistency)
# are partially automated — full analysis requires the AI-powered skill.
set -euo pipefail

# --- Configuration ---
CI_MODE=false
MIN_SCORE=80
VERBOSE=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --ci) CI_MODE=true; shift ;;
    --min-score) MIN_SCORE="$2"; shift 2 ;;
    --verbose|-v) VERBOSE=true; shift ;;
    --help|-h)
      echo "Usage: context-verify.sh [--ci] [--min-score N] [--verbose]"
      echo ""
      echo "Options:"
      echo "  --ci           CI mode: machine-readable output, exit 1 below threshold"
      echo "  --min-score N  Minimum passing score (default: 80)"
      echo "  --verbose      Show detailed check output"
      echo ""
      echo "Runs 10 automated context file health checks and produces a 0-100 score."
      echo "Works on any platform — no plugin or AI tool required."
      exit 0
      ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# --- Scoring ---
score=100
deductions=()
warnings=()
errors=()

deduct() {
  local points=$1
  local reason=$2
  score=$((score - points))
  if [ "$score" -lt 0 ]; then score=0; fi
  deductions+=("  -${points}: ${reason}")
}

warn() {
  warnings+=("  ! $1")
}

info() {
  if [ "$VERBOSE" = true ] || [ "$CI_MODE" = false ]; then
    echo "$1"
  fi
}

# --- Find project root (walk up to git root) ---
find_root() {
  local dir
  dir=$(git rev-parse --show-toplevel 2>/dev/null) || {
    echo "ERROR: Not in a git repository" >&2
    exit 1
  }
  echo "$dir"
}

ROOT=$(find_root)
cd "$ROOT"

# --- Detect context files ---
declare -a CONTEXT_FILES=()
declare -A FILE_ROLES=()

add_file() {
  local path=$1 role=$2
  if [ -f "$path" ]; then
    CONTEXT_FILES+=("$path")
    FILE_ROLES["$path"]="$role"
  fi
}

add_file "AGENTS.md" "canonical"
add_file "CLAUDE.md" "bridge"
add_file ".cursorrules" "bridge"
add_file ".github/copilot-instructions.md" "bridge"
add_file ".windsurfrules" "bridge"
add_file ".clinerules" "bridge"
add_file "GEMINI.md" "bridge"

if [ ${#CONTEXT_FILES[@]} -eq 0 ]; then
  echo "No AI context files found in ${ROOT}"
  echo "Run your AI tool's context generation command to create them."
  exit 0
fi

info "=== Context Verify — ${ROOT} ==="
info "Files found: ${#CONTEXT_FILES[@]}"
info ""

# ============================================================
# CHECK 1: Line Budget Compliance (max 20 points)
# ============================================================
info "--- Check 1: Line Budgets ---"
check1_deductions=0

for f in "${CONTEXT_FILES[@]}"; do
  lines=$(wc -l < "$f")
  role=${FILE_ROLES["$f"]}

  if [ "$role" = "canonical" ]; then
    # AGENTS.md: warning >120, over >160
    if [ "$lines" -gt 160 ]; then
      deduct 5 "${f}: ${lines} lines (budget: 160)"
      check1_deductions=$((check1_deductions + 5))
      info "  OVER: ${f} — ${lines} lines (max 160)"
    elif [ "$lines" -gt 120 ]; then
      deduct 2 "${f}: ${lines} lines (warning: 120)"
      check1_deductions=$((check1_deductions + 2))
      info "  WARN: ${f} — ${lines} lines (target: 120)"
    else
      info "  OK: ${f} — ${lines} lines"
    fi
  elif [ "$f" = "CLAUDE.md" ]; then
    # CLAUDE.md bridge: warning >20, over >80
    if [ "$lines" -gt 80 ]; then
      deduct 5 "${f}: ${lines} lines (budget: 80)"
      check1_deductions=$((check1_deductions + 5))
      info "  OVER: ${f} — ${lines} lines (max 80)"
    elif [ "$lines" -gt 20 ]; then
      deduct 2 "${f}: ${lines} lines (warning: 20)"
      check1_deductions=$((check1_deductions + 2))
      info "  WARN: ${f} — ${lines} lines (target: 20)"
    else
      info "  OK: ${f} — ${lines} lines"
    fi
  else
    # Other bridges: warning >20, over >60
    if [ "$lines" -gt 60 ]; then
      deduct 5 "${f}: ${lines} lines (budget: 60)"
      check1_deductions=$((check1_deductions + 5))
      info "  OVER: ${f} — ${lines} lines (max 60)"
    elif [ "$lines" -gt 20 ]; then
      deduct 2 "${f}: ${lines} lines (warning: 20)"
      check1_deductions=$((check1_deductions + 2))
      info "  WARN: ${f} — ${lines} lines (target: 20)"
    else
      info "  OK: ${f} — ${lines} lines"
    fi
  fi
done

# Cap check 1 deductions at 20
if [ "$check1_deductions" -gt 20 ]; then
  score=$((score + check1_deductions - 20))
fi
info ""

# ============================================================
# CHECK 2: Discoverable Content Detection (max 5 from signal quality)
# ============================================================
info "--- Check 2: Discoverable Content ---"
check2_count=0

for f in "${CONTEXT_FILES[@]}"; do
  # File tree characters
  if grep -qP '├──|└──|│\s+' "$f" 2>/dev/null; then
    check2_count=$((check2_count + 1))
    info "  FOUND: ${f} contains file tree characters (├── └──)"
  fi

  # "Project Structure" heading with content
  if grep -qi '^#.*project structure' "$f" 2>/dev/null; then
    check2_count=$((check2_count + 1))
    deduct 3 "${f}: contains 'Project Structure' section (discoverable)"
    info "  FOUND: ${f} has 'Project Structure' section"
  fi
done

# -1 per discoverable instance, max -5
discoverable_deduct=$((check2_count > 5 ? 5 : check2_count))
if [ "$check2_count" -gt 0 ] && [ "$discoverable_deduct" -gt 0 ]; then
  # Only deduct for tree characters (Project Structure already deducted above)
  tree_instances=$((check2_count - $(grep -rliP '^#.*project structure' "${CONTEXT_FILES[@]}" 2>/dev/null | wc -l)))
  if [ "$tree_instances" -gt 0 ]; then
    tree_deduct=$((tree_instances > 5 ? 5 : tree_instances))
    deduct "$tree_deduct" "Discoverable content: ${tree_instances} file tree instances"
  fi
fi
if [ "$check2_count" -eq 0 ]; then
  info "  OK: No discoverable content detected"
fi
info ""

# ============================================================
# CHECK 3: Stale Path Detection (max 10 from path accuracy)
# ============================================================
info "--- Check 3: Stale Paths ---"
stale_count=0
stale_max=5

for f in "${CONTEXT_FILES[@]}"; do
  # Extract backtick-quoted paths that look like file paths
  while IFS= read -r path; do
    # Skip empty, URLs, commands, variables, wildcards, templates
    [[ -z "$path" ]] && continue
    [[ "$path" =~ ^https?:// ]] && continue
    [[ "$path" =~ ^git@ ]] && continue
    [[ "$path" =~ ^\$ ]] && continue
    [[ "$path" =~ \* ]] && continue
    [[ "$path" =~ \<.*\> ]] && continue       # Template placeholders <name>
    [[ "$path" =~ ^npm|^pip|^curl|^bash|^python ]] && continue
    [[ "$path" =~ ^@ ]] && continue
    [[ "$path" =~ ^# ]] && continue
    [[ "$path" =~ : ]] && continue             # Slash commands, protocols
    [[ "$path" =~ ^/ ]] && continue            # Absolute paths (system refs)
    # Skip generic/example paths
    [[ "$path" =~ /\.\.\./|example|your- ]] && continue
    # Skip table-style documentation references (paths in | table | cells)
    # These describe what files look like, not actual project paths
    # Heuristic: skip if the path starts with . and contains no / (likely a file extension ref)
    # and also skip well-known bridge file names mentioned in documentation tables
    case "$path" in
      .cursorrules|.clinerules|.windsurfrules|.windsurfrules.md) continue ;;
      .github/copilot-instructions.md|.github/instructions/*) continue ;;
      .cursor/rules/*|.windsurf/rules/*|.windsurf/skills/*) continue ;;
      .clinerules/*|.agents/skills/*|.opencode/agents/*) continue ;;
      GEMINI.md|CONVENTIONS.md|CLAUDE.md|AGENTS.md) continue ;;
      gemini-extension.json|opencode.json|plugin.json) continue ;;
    esac
    # Must contain / to be treated as a relative path
    # Bare filenames (no /) are usually documentation references, not path assertions
    if [[ "$path" =~ / ]]; then
      # Skip ALL_CAPS
      [[ "$path" =~ ^[A-Z_]+$ ]] && continue
      # Normalise: strip trailing punctuation
      clean_path="${path%,}"
      clean_path="${clean_path%.}"
      clean_path="${clean_path%:}"
      clean_path="${clean_path%)}"
      if [ ! -e "$clean_path" ] && [ ! -d "$clean_path" ]; then
        stale_count=$((stale_count + 1))
        if [ "$stale_count" -le "$stale_max" ]; then
          info "  STALE: ${f}: \`${clean_path}\` not found"
        fi
      fi
    fi
  done < <(grep -oP '`([^`]+)`' "$f" 2>/dev/null | sed 's/^`//;s/`$//')
done

if [ "$stale_count" -gt 0 ]; then
  path_deduct=$((stale_count * 2))
  if [ "$path_deduct" -gt 10 ]; then path_deduct=10; fi
  deduct "$path_deduct" "Stale paths: ${stale_count} paths not found on disk"
  if [ "$stale_count" -gt "$stale_max" ]; then
    info "  ... and $((stale_count - stale_max)) more"
  fi
else
  info "  OK: All referenced paths exist"
fi
info ""

# ============================================================
# CHECK 4: AGENTS-to-Bridge Consistency (max 15 from consistency)
# ============================================================
info "--- Check 4: Bridge Consistency ---"

if [ -f "AGENTS.md" ]; then
  # Check CLAUDE.md has @AGENTS.md import
  if [ -f "CLAUDE.md" ]; then
    if ! grep -q '@AGENTS.md\|@agents.md' "CLAUDE.md" 2>/dev/null; then
      # Check if CLAUDE.md references AGENTS.md in some way
      if ! grep -qi 'AGENTS.md' "CLAUDE.md" 2>/dev/null; then
        deduct 2 "CLAUDE.md: missing @AGENTS.md import or reference"
        info "  WARN: CLAUDE.md does not reference AGENTS.md"
      else
        info "  OK: CLAUDE.md references AGENTS.md"
      fi
    else
      info "  OK: CLAUDE.md imports @AGENTS.md"
    fi
  fi

  # Check bridge files aren't larger than AGENTS.md (sign of duplication)
  agents_lines=$(wc -l < "AGENTS.md")
  for f in "${CONTEXT_FILES[@]}"; do
    [ "$f" = "AGENTS.md" ] && continue
    bridge_lines=$(wc -l < "$f")
    if [ "$bridge_lines" -gt "$agents_lines" ]; then
      deduct 3 "${f}: ${bridge_lines} lines > AGENTS.md ${agents_lines} lines (likely duplicating shared content)"
      info "  WARN: ${f} (${bridge_lines} lines) is longer than AGENTS.md (${agents_lines} lines)"
    fi
  done
else
  deduct 5 "No AGENTS.md found — cannot verify bridge consistency"
  info "  WARN: No AGENTS.md — bridges have no canonical source"
fi
info ""

# ============================================================
# CHECK 5: MEMORY.md Drift (max 2 from freshness)
# ============================================================
info "--- Check 5: MEMORY.md Drift ---"

# Look for MEMORY.md in common locations
memory_file=""
for candidate in "MEMORY.md" ".claude/MEMORY.md" ".claude/memory/MEMORY.md"; do
  if [ -f "$candidate" ]; then
    memory_file="$candidate"
    break
  fi
done

# Also check user-level memory for this project
if [ -z "$memory_file" ]; then
  # Check ~/.claude/projects/ for a project-specific MEMORY.md
  project_hash=$(echo "$ROOT" | sed 's|/|-|g; s|^-||')
  user_memory="$HOME/.claude/projects/${project_hash}/memory/MEMORY.md"
  if [ -f "$user_memory" ]; then
    memory_file="$user_memory"
  fi
fi

if [ -n "$memory_file" ]; then
  # Check for convention-like patterns not in CLAUDE.md
  convention_patterns=0
  if [ -f "CLAUDE.md" ]; then
    while IFS= read -r line; do
      # Look for "Always", "Never", "Use", "Prefer" patterns
      if echo "$line" | grep -qiP '^\s*-?\s*(always|never|use|prefer|don.t|do not)\b'; then
        # Check if this convention is already in CLAUDE.md
        keyword=$(echo "$line" | grep -oP '(always|never|use|prefer|don.t|do not)\s+\w+' | head -1)
        if [ -n "$keyword" ] && ! grep -qi "$keyword" "CLAUDE.md" 2>/dev/null; then
          convention_patterns=$((convention_patterns + 1))
        fi
      fi
    done < "$memory_file"
  fi

  if [ "$convention_patterns" -gt 0 ]; then
    deduct 2 "MEMORY.md: ${convention_patterns} convention patterns not yet promoted to CLAUDE.md"
    info "  WARN: ${convention_patterns} patterns in ${memory_file} could be promoted"
  else
    info "  OK: No unpromotable patterns detected"
  fi
else
  info "  SKIP: No MEMORY.md found"
fi
info ""

# ============================================================
# CHECK 6: Context Guard Status (informational, no score impact)
# ============================================================
info "--- Check 6: Context Guard Status ---"

hook_count=0
if [ -d ".claude/hooks" ]; then
  hook_count=$(find .claude/hooks -name 'context-*.sh' -type f 2>/dev/null | wc -l)
fi

settings_hooks=0
if [ -f ".claude/settings.json" ]; then
  # Check if hooks are registered
  if command -v jq &>/dev/null; then
    settings_hooks=$(jq -r '.hooks // {} | keys | length' .claude/settings.json 2>/dev/null || echo 0)
  fi
fi

if [ "$hook_count" -gt 0 ]; then
  info "  OK: ${hook_count} Context Guard hook scripts found"
  if [ "$settings_hooks" -gt 0 ]; then
    info "  OK: Hooks registered in settings.json (${settings_hooks} events)"
  else
    warn "Hook scripts exist but may not be registered in settings.json"
    info "  WARN: Hook scripts exist but no events in settings.json"
  fi
else
  info "  INFO: No Context Guard hooks installed (optional, Claude Code only)"
fi
info ""

# ============================================================
# CHECK 7: Context Load / Aggregate Token Estimate (max 10)
# ============================================================
info "--- Check 7: Context Load ---"

# Estimate tokens per tool based on which files they load
# Approximation: 1 token ≈ 4 characters for English markdown
estimate_tokens() {
  local file=$1
  if [ -f "$file" ]; then
    local chars
    chars=$(wc -c < "$file")
    echo $((chars / 4))
  else
    echo 0
  fi
}

# Claude Code loads: CLAUDE.md + AGENTS.md (via @import) + .claude/rules/*.md
claude_tokens=0
claude_tokens=$((claude_tokens + $(estimate_tokens "CLAUDE.md")))
claude_tokens=$((claude_tokens + $(estimate_tokens "AGENTS.md")))
if [ -d ".claude/rules" ]; then
  for f in .claude/rules/*.md; do
    [ -f "$f" ] || continue
    claude_tokens=$((claude_tokens + $(estimate_tokens "$f")))
  done
fi

# Codex CLI / OpenCode: AGENTS.md only (native)
codex_tokens=$(estimate_tokens "AGENTS.md")

# Cursor: .cursorrules + AGENTS.md + .cursor/rules/*.md
cursor_tokens=0
cursor_tokens=$((cursor_tokens + $(estimate_tokens ".cursorrules")))
cursor_tokens=$((cursor_tokens + $(estimate_tokens "AGENTS.md")))
if [ -d ".cursor/rules" ]; then
  for f in .cursor/rules/*.md .cursor/rules/*.mdc; do
    [ -f "$f" ] || continue
    cursor_tokens=$((cursor_tokens + $(estimate_tokens "$f")))
  done
fi

# Copilot: .github/copilot-instructions.md + AGENTS.md + .github/instructions/*.md
copilot_tokens=0
copilot_tokens=$((copilot_tokens + $(estimate_tokens ".github/copilot-instructions.md")))
copilot_tokens=$((copilot_tokens + $(estimate_tokens "AGENTS.md")))
if [ -d ".github/instructions" ]; then
  for f in .github/instructions/*.md; do
    [ -f "$f" ] || continue
    copilot_tokens=$((copilot_tokens + $(estimate_tokens "$f")))
  done
fi

# Gemini CLI: GEMINI.md (or AGENTS.md if configured)
gemini_tokens=$(($(estimate_tokens "GEMINI.md") + $(estimate_tokens "AGENTS.md")))

# Windsurf: .windsurfrules + AGENTS.md + .windsurf/rules/*.md
windsurf_tokens=0
windsurf_tokens=$((windsurf_tokens + $(estimate_tokens ".windsurfrules")))
windsurf_tokens=$((windsurf_tokens + $(estimate_tokens "AGENTS.md")))
if [ -d ".windsurf/rules" ]; then
  for f in .windsurf/rules/*.md; do
    [ -f "$f" ] || continue
    windsurf_tokens=$((windsurf_tokens + $(estimate_tokens "$f")))
  done
fi

# Cline: .clinerules + AGENTS.md
cline_tokens=0
cline_tokens=$((cline_tokens + $(estimate_tokens ".clinerules")))
cline_tokens=$((cline_tokens + $(estimate_tokens "AGENTS.md")))
if [ -d ".clinerules" ] && [ ! -f ".clinerules" ]; then
  for f in .clinerules/*.md .clinerules/*.txt; do
    [ -f "$f" ] || continue
    cline_tokens=$((cline_tokens + $(estimate_tokens "$f")))
  done
fi

# Report and score
declare -A tool_tokens=(
  ["Claude Code"]=$claude_tokens
  ["Codex CLI"]=$codex_tokens
  ["Cursor"]=$cursor_tokens
  ["Copilot"]=$copilot_tokens
  ["Gemini CLI"]=$gemini_tokens
  ["Windsurf"]=$windsurf_tokens
  ["Cline"]=$cline_tokens
)

for tool in "Claude Code" "Codex CLI" "Cursor" "Copilot" "Gemini CLI" "Windsurf" "Cline"; do
  tokens=${tool_tokens["$tool"]}
  if [ "$tokens" -eq 0 ]; then continue; fi

  if [ "$tokens" -gt 10000 ]; then
    deduct 5 "${tool}: ~${tokens} tokens (over 10K budget)"
    info "  OVER: ${tool} — ~${tokens} tokens"
  elif [ "$tokens" -gt 5000 ]; then
    deduct 3 "${tool}: ~${tokens} tokens (warning: 5K)"
    info "  WARN: ${tool} — ~${tokens} tokens"
  else
    info "  OK: ${tool} — ~${tokens} tokens"
  fi
done
info ""

# ============================================================
# CHECK 8: @import Path Validation (part of path accuracy)
# ============================================================
info "--- Check 8: @import Validation ---"
import_errors=0

for f in "${CONTEXT_FILES[@]}"; do
  while IFS= read -r import_path; do
    [[ -z "$import_path" ]] && continue
    if [ ! -f "$import_path" ]; then
      import_errors=$((import_errors + 1))
      info "  BROKEN: ${f}: @${import_path} — target not found"
    fi
  done < <(grep -oP '^@(.+)$' "$f" 2>/dev/null | sed 's/^@//')
done

if [ "$import_errors" -gt 0 ]; then
  deduct $((import_errors * 2)) "@import: ${import_errors} broken imports"
else
  info "  OK: All @imports resolve"
fi
info ""

# ============================================================
# CHECK 9: Rule Path-Scope Validation (part of path accuracy)
# ============================================================
info "--- Check 9: Rule Path Scopes ---"
orphaned_rules=0

if [ -d ".claude/rules" ]; then
  for f in .claude/rules/*.md; do
    [ -f "$f" ] || continue
    # Extract paths: from YAML frontmatter
    in_frontmatter=false
    in_paths=false
    while IFS= read -r line; do
      if [[ "$line" == "---" ]]; then
        if [ "$in_frontmatter" = true ]; then break; fi
        in_frontmatter=true
        continue
      fi
      if [ "$in_frontmatter" = true ]; then
        if [[ "$line" =~ ^paths: ]]; then
          in_paths=true
          continue
        fi
        if [ "$in_paths" = true ]; then
          if [[ "$line" =~ ^[[:space:]]+-[[:space:]] ]]; then
            glob_pattern=$(echo "$line" | sed 's/^[[:space:]]*-[[:space:]]*//' | tr -d '"' | tr -d "'")
            # Check if glob matches anything
            if ! compgen -G "$glob_pattern" >/dev/null 2>&1; then
              orphaned_rules=$((orphaned_rules + 1))
              info "  ORPHAN: ${f}: paths pattern '${glob_pattern}' matches nothing"
            fi
          else
            in_paths=false
          fi
        fi
      fi
    done < "$f"
  done
fi

if [ "$orphaned_rules" -gt 0 ]; then
  deduct $((orphaned_rules * 2)) "Rule path-scopes: ${orphaned_rules} patterns match no files"
else
  info "  OK: All rule path-scope patterns match files (or no path-scoped rules)"
fi
info ""

# ============================================================
# CHECK 10: Rule Symlink Targets (part of path accuracy)
# ============================================================
info "--- Check 10: Rule Symlinks ---"
broken_symlinks=0

if [ -d ".claude/rules" ]; then
  for f in .claude/rules/*.md; do
    if [ -L "$f" ]; then
      target=$(readlink "$f")
      if [ ! -e "$f" ]; then
        broken_symlinks=$((broken_symlinks + 1))
        info "  BROKEN: ${f} -> ${target} (target missing)"
      else
        info "  OK: ${f} -> ${target}"
      fi
    fi
  done
fi

if [ "$broken_symlinks" -gt 0 ]; then
  deduct $((broken_symlinks * 2)) "Rule symlinks: ${broken_symlinks} broken"
else
  info "  OK: No broken rule symlinks"
fi
info ""

# ============================================================
# CHECK 11: .mcp.json Validation (part of path accuracy)
# ============================================================
info "--- Check 11: .mcp.json ---"

if [ -f ".mcp.json" ]; then
  if command -v jq &>/dev/null; then
    if ! jq empty .mcp.json 2>/dev/null; then
      deduct 2 ".mcp.json: invalid JSON"
      info "  ERROR: .mcp.json is not valid JSON"
    elif ! jq -e '.mcpServers' .mcp.json >/dev/null 2>&1; then
      deduct 2 ".mcp.json: missing mcpServers object"
      info "  WARN: .mcp.json missing mcpServers object"
    else
      server_count=$(jq '.mcpServers | length' .mcp.json 2>/dev/null || echo 0)
      info "  OK: .mcp.json valid with ${server_count} servers"
    fi
  else
    info "  SKIP: jq not installed — cannot validate .mcp.json"
  fi
else
  info "  SKIP: No .mcp.json found"
fi
info ""

# ============================================================
# CHECK 12: Agent Memory Directory Hygiene (part of signal quality)
# ============================================================
info "--- Check 12: Agent Memory Hygiene ---"

memory_tracked=false
for dir in ".claude/agent-memory" ".claude/agent-memory-local"; do
  if [ -d "$dir" ]; then
    # Check if tracked in git
    if git ls-files --error-unmatch "$dir" >/dev/null 2>&1; then
      memory_tracked=true
      deduct 3 "${dir}: tracked in git (should be gitignored)"
      info "  WARN: ${dir} is tracked in git — add to .gitignore"
    fi
  fi
done

if [ "$memory_tracked" = false ]; then
  info "  OK: No agent memory directories tracked in git"
fi
info ""

# ============================================================
# CHECK 13: Plugin Manifest Completeness (part of consistency)
# ============================================================
info "--- Check 13: Plugin Manifest ---"

if [ -f ".claude-plugin/plugin.json" ]; then
  if command -v jq &>/dev/null; then
    missing_required=0
    missing_optional=0

    for field in name version description; do
      if ! jq -e ".${field}" .claude-plugin/plugin.json >/dev/null 2>&1; then
        missing_required=$((missing_required + 1))
        info "  MISSING: required field '${field}'"
      fi
    done

    for field in keywords author repository; do
      if ! jq -e ".${field}" .claude-plugin/plugin.json >/dev/null 2>&1; then
        missing_optional=$((missing_optional + 1))
        if [ "$VERBOSE" = true ]; then
          info "  OPTIONAL: field '${field}' not set"
        fi
      fi
    done

    if [ "$missing_required" -gt 0 ]; then
      deduct $((missing_required * 2)) "Plugin manifest: ${missing_required} required fields missing"
    fi

    if [ "$missing_required" -eq 0 ] && [ "$missing_optional" -eq 0 ]; then
      info "  OK: Plugin manifest complete"
    elif [ "$missing_required" -eq 0 ]; then
      info "  OK: Required fields present (${missing_optional} optional fields missing)"
    fi
  else
    info "  SKIP: jq not installed — cannot validate plugin.json"
  fi
else
  info "  SKIP: No plugin manifest found"
fi
info ""

# ============================================================
# CHECK 14: Modern Cursor Layout (part of path accuracy)
# ============================================================
info "--- Check 14: Cursor Layout ---"

cursor_legacy=false
cursor_modern=false
[ -f ".cursorrules" ] && cursor_legacy=true
if [ -d ".cursor/rules" ]; then
  for f in .cursor/rules/*.mdc .cursor/rules/*.md; do
    [ -f "$f" ] || continue
    cursor_modern=true
    break
  done
fi

if [ "$cursor_legacy" = true ] && [ "$cursor_modern" = false ]; then
  deduct 2 ".cursorrules: legacy single-file format; current Cursor versions ignore in Agent mode (migrate to .cursor/rules/agents.mdc)"
  info "  WARN: Only .cursorrules present — current Cursor ignores this in Agent mode"
elif [ "$cursor_legacy" = true ] && [ "$cursor_modern" = true ]; then
  info "  INFO: Both .cursorrules and .cursor/rules/ present — legacy file is redundant"
elif [ "$cursor_modern" = true ]; then
  info "  OK: Modern .cursor/rules/ layout in use"
else
  info "  SKIP: No Cursor context files present"
fi
info ""

# ============================================================
# CHECK 15: Modern Cline Layout (part of path accuracy)
# ============================================================
info "--- Check 15: Cline Layout ---"

if [ -d ".clinerules" ]; then
  cline_dir_files=0
  for f in .clinerules/*.md; do
    [ -f "$f" ] || continue
    cline_dir_files=$((cline_dir_files + 1))
  done
  if [ "$cline_dir_files" -gt 0 ]; then
    info "  OK: .clinerules/ directory mode in use (${cline_dir_files} files)"
  else
    info "  WARN: .clinerules/ directory exists but is empty"
  fi
elif [ -f ".clinerules" ]; then
  deduct 2 ".clinerules: flat-file format; consider migrating to .clinerules/ directory mode for path-scoped rules"
  info "  WARN: Flat .clinerules file — directory mode supports path-scoped rules"
else
  info "  SKIP: No Cline context files present"
fi
info ""

# ============================================================
# CHECK 16: Copilot Bridge Optionality (advisory only, no deduction)
# ============================================================
info "--- Check 16: Copilot Bridge Optionality ---"

if [ -f ".github/copilot-instructions.md" ] && [ -f "AGENTS.md" ]; then
  copilot_lines=$(grep -cv '^[[:space:]]*$' .github/copilot-instructions.md 2>/dev/null || echo 0)
  if [ "$copilot_lines" -lt 10 ]; then
    info "  ADVISORY: .github/copilot-instructions.md is short — Copilot loads AGENTS.md natively (since Aug 2025); consider deleting if it duplicates AGENTS.md"
  else
    info "  OK: Copilot bridge has tool-specific content (${copilot_lines} non-blank lines)"
  fi
else
  info "  SKIP: No Copilot bridge or no AGENTS.md"
fi
info ""

# ============================================================
# CHECK 17: Freshness (stale >90 days) (part of freshness score)
# ============================================================
info "--- Check 17: Freshness ---"
stale_files=0

for f in "${CONTEXT_FILES[@]}"; do
  if git log -1 --format="%at" -- "$f" >/dev/null 2>&1; then
    last_modified=$(git log -1 --format="%at" -- "$f" 2>/dev/null || echo 0)
    now=$(date +%s)
    age_days=$(( (now - last_modified) / 86400 ))
    if [ "$age_days" -gt 90 ]; then
      stale_files=$((stale_files + 1))
      deduct 3 "${f}: last modified ${age_days} days ago"
      info "  STALE: ${f} — ${age_days} days since last update"
    elif [ "$age_days" -gt 60 ]; then
      info "  AGING: ${f} — ${age_days} days since last update"
    else
      info "  OK: ${f} — ${age_days} days old"
    fi
  fi
done
info ""

# ============================================================
# REPORT
# ============================================================
echo "=== Health Score ==="
echo ""

# Determine grade
grade=""
label=""
if [ "$score" -ge 90 ]; then
  grade="A"; label="Lean and current"
elif [ "$score" -ge 80 ]; then
  grade="B"; label="Minor tuning needed"
elif [ "$score" -ge 70 ]; then
  grade="C"; label="Needs attention"
elif [ "$score" -ge 60 ]; then
  grade="D"; label="Significant drift"
else
  grade="F"; label="Overhaul recommended"
fi

echo "Score: ${score}/100 (${grade} — ${label})"
echo ""

if [ ${#deductions[@]} -gt 0 ]; then
  echo "Deductions:"
  for d in "${deductions[@]}"; do
    echo "$d"
  done
  echo ""
fi

if [ ${#warnings[@]} -gt 0 ]; then
  echo "Warnings:"
  for w in "${warnings[@]}"; do
    echo "$w"
  done
  echo ""
fi

# CI mode: exit with appropriate code
if [ "$CI_MODE" = true ]; then
  echo "ci_score=${score}"
  echo "ci_grade=${grade}"
  echo "ci_threshold=${MIN_SCORE}"
  if [ "$score" -lt "$MIN_SCORE" ]; then
    echo "FAIL: Score ${score} is below threshold ${MIN_SCORE}"
    exit 1
  else
    echo "PASS: Score ${score} meets threshold ${MIN_SCORE}"
    exit 0
  fi
fi
