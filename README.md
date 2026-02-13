# configs

My configuration files for tmux, neovim, and bash.

## Contents

```
configs/
├── tmux/.tmux.conf        # tmux configuration
├── nvim/
│   ├── init.lua           # entry point — sources init.vim, then applies Lua config
│   ├── init.vim           # current vimscript configuration
│   └── coc-settings.json  # CoC language server settings
├── bash/.bashrc_ext       # bash extensions (aliases, functions, etc.)
├── install.sh             # symlink installer
└── README.md
```

## Setup on a new server

1. Clone this repo:

```bash
git clone <your-repo-url> ~/configs
cd ~/configs
```

2. Run the install script to create symlinks:

```bash
chmod +x install.sh
./install.sh
```

This creates the following symlinks:

| Symlink | Points to |
|---|---|
| `~/.tmux.conf` | `~/configs/tmux/.tmux.conf` |
| `~/.config/nvim` | `~/configs/nvim/` |
| `~/.bashrc_ext` | `~/configs/bash/.bashrc_ext` |

### Neovim migration path

The nvim config supports both vimscript and Lua simultaneously:

- `init.lua` is the entry point neovim loads. It sources `init.vim` first, then applies any Lua settings.
- Put your current vimscript config in `init.vim`.
- As you migrate to Lua, move settings from `init.vim` into `init.lua` and delete them from `init.vim`.

If a file already exists at the symlink location, it is backed up to `<filename>.bak`.

3. Source the bash extensions by adding this line to your `~/.bashrc`:

```bash
if [ -f ~/.bashrc_ext ]; then . ~/.bashrc_ext; fi
```

## Updating

Since configs are symlinked, pulling new changes takes effect immediately:

```bash
cd ~/configs && git pull
```

For tmux, reload with `tmux source-file ~/.tmux.conf`. For bash, start a new shell or run `source ~/.bashrc`.
