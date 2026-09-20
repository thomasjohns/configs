# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A dotfiles repository containing personal configuration files for tmux, neovim, shell (bash/zsh), VS Code, Zed, Claude Code, Codex, and Ghostty. Configs are installed via symlinks from `install.sh`.

## Repository Structure

- `shell/.shellrc_ext` — Shell aliases and functions, compatible with bash and zsh (sourced from `~/.bashrc` or `~/.zshrc`)
- `nvim/` — Neovim config with dual vimscript/Lua setup (`init.lua` sources `init.vim` first)
- `tmux/.tmux.conf` — Tmux configuration
- `vscode/` — VS Code settings and keybindings (symlinked to both local and remote SSH paths)
- `zed/` — Zed settings and keymap
- `claude/settings.json` — Claude Code global settings (symlinked to `~/.claude/settings.json`)
- `codex/config.toml` — Codex CLI global config (symlinked to `~/.codex/config.toml`)
- `ghostty/config.ghostty` — Ghostty config (symlinked to `~/.config/ghostty/config.ghostty`; Ghostty 1.3 looks for `config.ghostty`, not `config`)
- `install.sh` — Symlink installer + plugin manager bootstrap (vim-plug, TPM)

## Setup

```bash
./install.sh
```

This creates symlinks, installs vim-plug, runs `:PlugInstall`, and sets up TPM for tmux.

## Key Conventions

- **Neovim migration path**: `init.lua` is the entry point. It sources `init.vim` for existing vimscript config. New config should go in `init.lua`; migrated settings should be removed from `init.vim`.
- **Shell utilities**: Uses `eza` (not `ls`), `rg` (ripgrep), and `sd` as assumed dependencies. All functions in `.shellrc_ext` are compatible with both bash and zsh. The `wt` function handles git worktree creation for both bare and normal repos, including copying gitignored files and auto-excluding worktree dirs.
- **VS Code configs** are symlinked to two locations each (local desktop and vscode-server remote SSH).
- **Only non-secret config is tracked**: `~/.claude.json` and `~/.codex/auth.json` hold credentials and session state and must never be added to this repo. Keep API keys out of `claude/settings.json` too.
