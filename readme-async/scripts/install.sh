#!/usr/bin/env bash
# install.sh — Install readme-async skill into a project
# Usage: ./scripts/install.sh [target-project-path]

set -euo pipefail

SKILL_NAME="readme-async"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_SOURCE_DIR="$(dirname "$SCRIPT_DIR")"
TARGET_DIR="${1:-$(pwd)}"

log() { printf '\033[1;32m[INFO]\033[0m %s\n' "$*"; }
err() { printf '\033[1;31m[ERROR]\033[0m %s\n' "$*" >&2; }
warn() { printf '\033[1;33m[WARN]\033[0m %s\n' "$*"; }

main() {
  log "Installing $SKILL_NAME skill..."
  log "Source: $SKILL_SOURCE_DIR"
  log "Target: $TARGET_DIR"

  # Validate target
  if [[ ! -d "$TARGET_DIR" ]]; then
    err "Target directory not found: $TARGET_DIR"
    exit 1
  fi

  local skills_dir="$TARGET_DIR/.claude/skills"
  local target_skill_dir="$skills_dir/$SKILL_NAME"

  # Create .claude/skills if needed
  mkdir -p "$skills_dir"

  # Check if already installed
  if [[ -d "$target_skill_dir" ]]; then
    warn "Skill already installed at $target_skill_dir"
    read -p "Overwrite? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      log "Installation cancelled"
      exit 0
    fi
    rm -rf "$target_skill_dir"
  fi

  # Copy skill files (excluding scripts/ folder and any install scripts)
  log "Copying skill files..."
  rsync -av --exclude='scripts/' --exclude='install.sh' --exclude='install.ps1' "$SKILL_SOURCE_DIR/" "$target_skill_dir/"

  log "Skill installed successfully at $target_skill_dir"
  log ""
  log "To use the skill, run:"
  log "  /skill readme-async"
  log ""
  log "Or add to your CLAUDE.md:"
  log "  - readme-async: Keep README.md synchronized with codebase"
}

main "$@"