#!/usr/bin/env bash

set -euo pipefail

DRY_RUN=0

usage() {
  cat <<USAGE
Usage: $(basename "$0") [--dry-run]

Options:
  --dry-run   Print actions without changing files.
  -h, --help  Show this help.
USAGE
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dry-run)
        DRY_RUN=1
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
}

repo_root() {
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  cd "$script_dir/.." && pwd
}

run() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf '[dry-run] %q' "$1"
    shift
    printf ' %q' "$@"
    printf '\n'
  else
    "$@"
  fi
}

assert_repo_root() {
  local root="$1"

  if [[ ! -d "$root/skills" || ! -f "$root/README.md" ]]; then
    echo "This script must be run from the work-flow-skill-sean repository." >&2
    exit 1
  fi
}

skill_names() {
  local root="$1"
  local skill

  for skill in "$root"/skills/*; do
    [[ -d "$skill" ]] || continue
    basename "$skill"
  done
}

install_skills() {
  local target_root="$1"
  local label="$2"
  local root name src dest

  root="$(repo_root)"
  assert_repo_root "$root"

  echo "Installing skills to $label: $target_root"
  run mkdir -p "$target_root"

  while IFS= read -r name; do
    src="$root/skills/$name"
    dest="$target_root/$name"

    if [[ ! -f "$src/SKILL.md" ]]; then
      echo "Missing SKILL.md in source skill: $src" >&2
      exit 1
    fi

    echo "Installing $name"
    run rm -rf "$dest"
    run mkdir -p "$dest"
    run cp -R "$src"/. "$dest"/

    if [[ "$DRY_RUN" -eq 0 && ! -f "$dest/SKILL.md" ]]; then
      echo "Install verification failed: $dest/SKILL.md not found" >&2
      exit 1
    fi
  done < <(skill_names "$root")

  echo "Done. Restart or start a new $label session to load the updated skills."
}

uninstall_skills() {
  local target_root="$1"
  local label="$2"
  local root name dest

  root="$(repo_root)"
  assert_repo_root "$root"

  echo "Uninstalling repository-managed skills from $label: $target_root"

  while IFS= read -r name; do
    dest="$target_root/$name"

    if [[ -e "$dest" || -L "$dest" ]]; then
      echo "Removing $name"
      run rm -rf "$dest"
    else
      echo "Skipping $name (not installed)"
    fi
  done < <(skill_names "$root")

  echo "Done."
}
