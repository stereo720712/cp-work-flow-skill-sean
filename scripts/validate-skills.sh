#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_DIR="$ROOT/skills"
CODEX_QUICK_VALIDATE="$HOME/.codex/skills/.system/skill-creator/scripts/quick_validate.py"
STRICT_CODEX=0

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

extract_frontmatter_value() {
  local file="$1"
  local key="$2"

  awk -v key="$key" '
    NR == 1 {
      if ($0 != "---") exit 0
      in_fm = 1
      next
    }
    in_fm && $0 == "---" { exit 0 }
    in_fm {
      pattern = "^" key ":[[:space:]]*"
      if ($0 ~ pattern) {
        sub(pattern, "", $0)
        gsub(/^["'\'']|["'\'']$/, "", $0)
        print $0
        exit 0
      }
    }
  ' "$file"
}

usage() {
  cat <<USAGE
Usage: $(basename "$0") [--strict-codex]

Options:
  --strict-codex  Fail when Codex quick_validate.py reports an issue.
  -h, --help      Show this help.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --strict-codex)
      STRICT_CODEX=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

[[ -d "$SKILLS_DIR" ]] || fail "skills directory not found: $SKILLS_DIR"

echo "Validating skill source: $SKILLS_DIR"

while IFS= read -r skill_dir; do
  [[ -d "$skill_dir" ]] || continue

  name="$(basename "$skill_dir")"
  skill_file="$skill_dir/SKILL.md"

  echo "Checking $name"

  [[ -f "$skill_file" ]] || fail "$name missing SKILL.md"

  frontmatter_name="$(extract_frontmatter_value "$skill_file" "name")"
  description_line="$(extract_frontmatter_value "$skill_file" "description")"

  [[ -n "$frontmatter_name" ]] || fail "$name missing frontmatter name"
  [[ -n "$description_line" ]] || fail "$name missing frontmatter description"
  [[ "$frontmatter_name" == "$name" ]] || fail "$name frontmatter name does not match folder name: $frontmatter_name"

  codex_status=0
  codex_output=""

  if [[ -x "$CODEX_QUICK_VALIDATE" ]]; then
    codex_output="$("$CODEX_QUICK_VALIDATE" "$skill_dir" 2>&1)" || codex_status=$?
  elif [[ -f "$CODEX_QUICK_VALIDATE" ]]; then
    codex_output="$(python3 "$CODEX_QUICK_VALIDATE" "$skill_dir" 2>&1)" || codex_status=$?
  else
    echo "WARN: Codex quick_validate.py not found, skipped Codex-specific validation: $CODEX_QUICK_VALIDATE" >&2
  fi

  if [[ "$codex_status" -ne 0 ]]; then
    if [[ "$STRICT_CODEX" -eq 1 ]]; then
      echo "$codex_output" >&2
      fail "$name failed Codex quick_validate.py"
    fi
    echo "WARN: $name failed Codex quick_validate.py: $codex_output" >&2
  fi
done < <(find "$SKILLS_DIR" -mindepth 1 -maxdepth 1 -type d | sort)

echo "Checking Claude install compatibility with dry-run"
"$SCRIPT_DIR/install-claude.sh" --dry-run >/dev/null

echo "All skill validations passed."
