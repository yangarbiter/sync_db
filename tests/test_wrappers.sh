#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export OBSIDIAN_VAULT
OBSIDIAN_VAULT="$(mktemp -d)"
export OBSIDIAN_COMMANDS_SUBDIR="logs"

# shellcheck source=../obsidian_sync_common.sh
source "$ROOT_DIR/obsidian_sync_common.sh"

current_branch="$(git -C "$ROOT_DIR" rev-parse --abbrev-ref HEAD)"
current_commit="$(git -C "$ROOT_DIR" rev-parse --short=7 HEAD)"

_obsidian_sync_write_row "bash" "0" "$ROOT_DIR" "echo hello | cat"

log_file="$OBSIDIAN_VAULT/logs/$(date '+%Y-%m-%d').md"
[[ -f "$log_file" ]] || { echo "missing log file"; exit 1; }

grep -q "# Command Log" "$log_file"
grep -q "Time (Local)" "$log_file"
grep -q "Git Branch" "$log_file"
grep -q "Git Commit" "$log_file"
grep -q "echo hello \\| cat" "$log_file"
grep -q "| bash | 0 |" "$log_file"
grep -q "| $current_branch | $current_commit |" "$log_file"

echo "tests passed"
