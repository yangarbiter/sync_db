# sync_db

Shell wrappers that sync command history into an Obsidian vault.

## What this does

These wrappers append every interactive shell command you run to a daily Markdown file in your Obsidian vault:

- Bash via `PROMPT_COMMAND`
- Zsh via `preexec` + `precmd` hooks

Each entry includes UTC timestamp, local command time, shell, exit code, git branch/commit (when in a git repo), working directory, and command.

## 1) Set up your Obsidian vault

If you already have a vault, note its filesystem path and use that as `OBSIDIAN_VAULT`.

If you do **not** have one yet:

1. Open Obsidian.
2. Click **Create new vault**.
3. Pick a vault name and location (example: `$HOME/Obsidian/MyVault`).
4. Confirm the vault opens, then copy the full path.

## 2) Install these scripts

Pick a location that is stable on your machine (for example `~/.local/share/sync_db`) and copy this repo there.

Example install commands:

```bash
mkdir -p ~/.local/share
cp -R /workspace/sync_db ~/.local/share/sync_db
```

> If you cloned this repo directly to a permanent location, you can skip the copy step.

## 3) Configure environment variables

Set your vault path (required):

```bash
export OBSIDIAN_VAULT="$HOME/Obsidian/MyVault"
```

Optional: customize the subdirectory inside the vault (default is `command-log`):

```bash
export OBSIDIAN_COMMANDS_SUBDIR="command-log"
```

## 4) Enable for Bash

Add this line to `~/.bashrc`:

```bash
source ~/.local/share/sync_db/obsidian_sync_bash.sh
```

Reload shell:

```bash
source ~/.bashrc
```

## 5) Enable for Zsh

Add this line to `~/.zshrc`:

```zsh
source ~/.local/share/sync_db/obsidian_sync_zsh.zsh
```

Reload shell:

```zsh
source ~/.zshrc
```

## Log output

Logs are written to:

`$OBSIDIAN_VAULT/$OBSIDIAN_COMMANDS_SUBDIR/YYYY-MM-DD.md`

Example:

`$HOME/Obsidian/MyVault/command-log/2026-04-13.md`
