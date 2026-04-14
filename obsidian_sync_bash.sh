#!/usr/bin/env bash

# Source this file from ~/.bashrc to log executed commands to Obsidian.

# shellcheck source=./obsidian_sync_common.sh
source "${BASH_SOURCE%/*}/obsidian_sync_common.sh"

_obsidian_sync_bash_prompt_hook() {
  local exit_code cmd
  exit_code=$?
  cmd="$(HISTTIMEFORMAT= history 1 | sed 's/^ *[0-9]\+ *//')"

  if [[ -z "$cmd" || "$cmd" == "$OBSIDIAN_SYNC_BASH_LAST_CMD" ]]; then
    return 0
  fi

  OBSIDIAN_SYNC_BASH_LAST_CMD="$cmd"
  export OBSIDIAN_SYNC_BASH_LAST_CMD

  _obsidian_sync_write_row "bash" "$exit_code" "$PWD" "$cmd"
}

if [[ ";${PROMPT_COMMAND:-};" != *";_obsidian_sync_bash_prompt_hook;"* ]]; then
  if [[ -n "${PROMPT_COMMAND:-}" ]]; then
    PROMPT_COMMAND="_obsidian_sync_bash_prompt_hook;${PROMPT_COMMAND}"
  else
    PROMPT_COMMAND="_obsidian_sync_bash_prompt_hook"
  fi
fi
