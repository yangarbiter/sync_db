#!/usr/bin/env sh

# Shared command logging helpers for shell wrappers.

_obsidian_sync_init() {
  if [ -n "${OBSIDIAN_SYNC_INITIALIZED:-}" ]; then
    return 0
  fi

  OBSIDIAN_VAULT="${OBSIDIAN_VAULT:-$HOME/Obsidian}"
  OBSIDIAN_COMMANDS_SUBDIR="${OBSIDIAN_COMMANDS_SUBDIR:-command-log}"
  OBSIDIAN_SYNC_INITIALIZED=1
  export OBSIDIAN_VAULT OBSIDIAN_COMMANDS_SUBDIR OBSIDIAN_SYNC_INITIALIZED
}

_obsidian_sync_log_file() {
  _obsidian_sync_init
  local day
  day="$(date '+%Y-%m-%d')"
  printf '%s/%s/%s.md' "$OBSIDIAN_VAULT" "$OBSIDIAN_COMMANDS_SUBDIR" "$day"
}

_obsidian_sync_ensure_header() {
  local file
  file="$1"
  [ -f "$file" ] && return 0

  mkdir -p "$(dirname "$file")" || return 1

  {
    printf '# Command Log %s\n\n' "$(date '+%Y-%m-%d')"
    printf '| Timestamp (UTC) | Time (Local) | Hostname | Shell | Exit | Git Branch | Git Commit | Dir | Command |\n'
    printf '|---|---|---|---|---:|---|---|---|---|\n'
  } >"$file"
}

_obsidian_sync_escape_pipes() {
  printf '%s' "$1" | sed 's/|/\\|/g'
}

_obsidian_sync_git_info() {
  local dir branch commit
  dir="$1"

  if ! command -v git >/dev/null 2>&1; then
    printf '%s|%s' "-" "-"
    return 0
  fi

  if ! git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    printf '%s|%s' "-" "-"
    return 0
  fi

  branch="$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null || printf '%s' '-')"
  commit="$(git -C "$dir" rev-parse --short=7 HEAD 2>/dev/null || printf '%s' '-')"

  [ -z "$branch" ] && branch="-"
  [ -z "$commit" ] && commit="-"

  printf '%s|%s' "$branch" "$commit"
}

_obsidian_sync_write_row() {
  local shell_name exit_code dir cmd ts_utc ts_local file git_info git_branch git_commit hostname
  shell_name="$1"
  exit_code="$2"
  dir="$3"
  cmd="$4"

  [ -z "$cmd" ] && return 0

  file="$(_obsidian_sync_log_file)"
  _obsidian_sync_ensure_header "$file" || return 1

  ts_utc="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
  ts_local="$(date '+%H:%M:%S')"
  hostname="$(hostname 2>/dev/null || printf '%s' '-')"
  [ -z "$hostname" ] && hostname="-"

  git_info="$(_obsidian_sync_git_info "$dir")"
  git_branch="${git_info%%|*}"
  git_commit="${git_info#*|}"

  hostname="$(_obsidian_sync_escape_pipes "$hostname")"
  dir="$(_obsidian_sync_escape_pipes "$dir")"
  cmd="$(_obsidian_sync_escape_pipes "$cmd")"
  git_branch="$(_obsidian_sync_escape_pipes "$git_branch")"
  git_commit="$(_obsidian_sync_escape_pipes "$git_commit")"

  printf '| %s | %s | %s | %s | %s | %s | %s | `%s` | `%s` |\n' \
    "$ts_utc" "$ts_local" "$hostname" "$shell_name" "$exit_code" "$git_branch" "$git_commit" "$dir" "$cmd" >>"$file"
}
