# configs

My configuration files for tmux, neovim, shell, VS Code, Zed, Claude Code, Codex, and Ghostty.

## Contents

```
configs/
├── tmux/.tmux.conf        # tmux configuration
├── nvim/
│   ├── init.lua           # entry point — sources init.vim, then applies Lua config
│   ├── init.vim           # current vimscript configuration
│   └── coc-settings.json  # CoC language server settings
├── shell/.shellrc_ext     # shell extensions (aliases, functions) for bash and zsh
├── vscode/
│   ├── settings.json      # VS Code settings (local + remote SSH)
│   └── keybindings.json   # VS Code keybindings (neovim-style)
├── zed/
│   ├── settings.json      # Zed settings (vim mode, gruvbox, etc.)
│   └── keymap.json        # Zed keymap mirroring the nvim/VS Code bindings
├── claude/settings.json   # Claude Code global settings (model, effort, vim editor mode)
├── codex/config.toml      # Codex CLI global config (model, effort, vim mode)
├── ghostty/config.ghostty # Ghostty terminal config (theme)
├── install.sh             # symlink installer + plugin setup
└── README.md
```

## Prerequisites

The install script will set everything up, but the following should be installed first:

- **git** — required for cloning plugin managers
- **curl** — required for downloading vim-plug
- **neovim** — install via your package manager (e.g. `apt install neovim`)
- **tmux** — install via your package manager (e.g. `apt install tmux`)
- **node.js** — required by CoC (e.g. `apt install nodejs npm`)

## Setup on a new server

1. Clone this repo:

```bash
git clone https://github.com/thomasjohns/configs ~/configs
cd ~/configs
```

2. Run the install script:

```bash
chmod +x install.sh
./install.sh
```

The script will:

- Create symlinks for all config files (backing up any existing files to `.bak`)
- Install [vim-plug](https://github.com/junegunn/vim-plug) if not already present
- Run `nvim +PlugInstall +qall` to install all neovim plugins headlessly
- Clone [TPM](https://github.com/tmux-plugins/tpm) and install tmux plugins (tmux-yank)

### Symlinks created

| Symlink | Points to |
|---|---|
| `~/.tmux.conf` | `~/configs/tmux/.tmux.conf` |
| `~/.config/nvim` | `~/configs/nvim/` |
| `~/.shellrc_ext` | `~/configs/shell/.shellrc_ext` |
| `~/.config/Code/User/settings.json` | `~/configs/vscode/settings.json` |
| `~/.vscode-server/data/Machine/settings.json` | `~/configs/vscode/settings.json` |
| `~/.config/Code/User/keybindings.json` | `~/configs/vscode/keybindings.json` |
| `~/.vscode-server/data/Machine/keybindings.json` | `~/configs/vscode/keybindings.json` |
| `~/.config/zed/settings.json` | `~/configs/zed/settings.json` |
| `~/.config/zed/keymap.json` | `~/configs/zed/keymap.json` |
| `~/.claude/settings.json` | `~/configs/claude/settings.json` |
| `~/.codex/config.toml` | `~/configs/codex/config.toml` |
| `~/.config/ghostty/config.ghostty` | `~/configs/ghostty/config.ghostty` |

3. Source the shell extensions by adding this line to your `~/.bashrc` or `~/.zshrc`:

```bash
if [ -f ~/.shellrc_ext ]; then . ~/.shellrc_ext; fi
```

4. Open neovim once to let CoC auto-install its extensions (coc-omnisharp, coc-prettier, coc-pyright).

### Neovim migration path

The nvim config supports both vimscript and Lua simultaneously:

- `init.lua` is the entry point neovim loads. It sources `init.vim` first, then applies any Lua settings.
- Put your current vimscript config in `init.vim`.
- As you migrate to Lua, move settings from `init.vim` into `init.lua` and delete them from `init.vim`.

## Ansible provisioning

The following tasks can be added to an Ansible playbook to fully provision a new server with these configs. Adjust `ansible_user_dir` as needed.

```yaml
- name: Install prerequisites
  become: true
  ansible.builtin.apt:
    name:
      - git
      - curl
      - tmux
      - neovim
      - nodejs
      - npm
    state: present
    update_cache: true

- name: Clone configs repo
  ansible.builtin.git:
    repo: "https://github.com/thomasjohns/configs"
    dest: "{{ ansible_user_dir }}/configs"
    version: main

- name: Run install script
  ansible.builtin.shell: "{{ ansible_user_dir }}/configs/install.sh"
  args:
    executable: /bin/bash

- name: Source shell extensions from ~/.bashrc
  ansible.builtin.lineinfile:
    path: "{{ ansible_user_dir }}/.bashrc"
    line: 'if [ -f ~/.shellrc_ext ]; then . ~/.shellrc_ext; fi'
    state: present
```

> **Note:** CoC extensions will auto-install on first interactive neovim session. To provision them non-interactively, add the following task:

```yaml
- name: Install CoC extensions headlessly
  ansible.builtin.shell: >
    nvim --headless
    +"CocInstall -sync coc-omnisharp coc-prettier coc-pyright"
    +qall
  args:
    executable: /bin/bash
```

## Updating

Since configs are symlinked, pulling new changes takes effect immediately:

```bash
cd ~/configs && git pull
```

Claude Code and Codex read their settings on launch, so restart them after a change. Ghostty reloads with `cmd+shift+,`. For neovim plugins, run `:PlugUpdate` inside neovim. For tmux plugins, press `prefix + U` in tmux. For the shell extensions, start a new shell or re-source your `~/.bashrc` or `~/.zshrc`. For tmux, reload with `tmux source-file ~/.tmux.conf`.
