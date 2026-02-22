# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A dotfiles repository containing personal configuration files for tmux, neovim, bash, and VS Code. Configs are installed via symlinks from `install.sh`.

## Repository Structure

- `bash/.bashrc_ext` — Bash aliases and shell functions (sourced from `~/.bashrc`)
- `nvim/` — Neovim config with dual vimscript/Lua setup (`init.lua` sources `init.vim` first)
- `tmux/.tmux.conf` — Tmux configuration
- `vscode/` — VS Code settings and keybindings (symlinked to both local and remote SSH paths)
- `install.sh` — Symlink installer + plugin manager bootstrap (vim-plug, TPM)

## Setup

```bash
./install.sh
```

This creates symlinks, installs vim-plug, runs `:PlugInstall`, and sets up TPM for tmux.

## Key Conventions

- **Neovim migration path**: `init.lua` is the entry point. It sources `init.vim` for existing vimscript config. New config should go in `init.lua`; migrated settings should be removed from `init.vim`.
- **Bash utilities**: Uses `eza` (not `ls`), `rg` (ripgrep), and `sd` as assumed dependencies. The `wt` function handles git worktree creation for both bare and normal repos, including copying gitignored files and auto-excluding worktree dirs.
- **VS Code configs** are symlinked to two locations each (local desktop and vscode-server remote SSH).
