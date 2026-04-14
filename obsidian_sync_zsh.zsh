#!/usr/bin/env zsh

# Source this file from ~/.zshrc to log executed commands to Obsidian.

source "${${(%):-%x}:A:h}/obsidian_sync_common.sh"

typeset -g OBSIDIAN_SYNC_ZSH_LAST_CMD=""
typeset -g OBSIDIAN_SYNC_ZSH_PENDING_CMD=""

_obsidian_sync_zsh_preexec() {
  OBSIDIAN_SYNC_ZSH_PENDING_CMD="$1"
}

_obsidian_sync_zsh_precmd() {
  local exit_code
  exit_code=$?

  if [[ -z "$OBSIDIAN_SYNC_ZSH_PENDING_CMD" || "$OBSIDIAN_SYNC_ZSH_PENDING_CMD" == "$OBSIDIAN_SYNC_ZSH_LAST_CMD" ]]; then
    return 0
  fi

  OBSIDIAN_SYNC_ZSH_LAST_CMD="$OBSIDIAN_SYNC_ZSH_PENDING_CMD"
  _obsidian_sync_write_row "zsh" "$exit_code" "$PWD" "$OBSIDIAN_SYNC_ZSH_PENDING_CMD"
}

autoload -Uz add-zsh-hook
add-zsh-hook preexec _obsidian_sync_zsh_preexec
add-zsh-hook precmd _obsidian_sync_zsh_precmd
