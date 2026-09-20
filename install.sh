#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

# --- Symlinks ---

link_file() {
    local source_path="$1"
    local target="$2"

    mkdir -p "$(dirname "$target")"

    if [ -L "$target" ]; then
        echo "Removing existing symlink: $target"
        rm "$target"
    elif [ -e "$target" ]; then
        echo "Backing up existing file: $target -> ${target}.bak"
        mv "$target" "${target}.bak"
    fi

    ln -s "$source_path" "$target"
    echo "Linked: $target -> $source_path"
}

link_file "$REPO_DIR/tmux/.tmux.conf"    "$HOME/.tmux.conf"
link_file "$REPO_DIR/nvim"               "$HOME/.config/nvim"
link_file "$REPO_DIR/shell/.shellrc_ext"  "$HOME/.shellrc_ext"

# VS Code settings.json is symlinked to two locations (local + remote SSH)
link_file "$REPO_DIR/vscode/settings.json" "$HOME/.config/Code/User/settings.json"
link_file "$REPO_DIR/vscode/settings.json" "$HOME/.vscode-server/data/Machine/settings.json"

# VS Code keybindings.json is symlinked to two locations (local + remote SSH)
link_file "$REPO_DIR/vscode/keybindings.json" "$HOME/.config/Code/User/keybindings.json"
link_file "$REPO_DIR/vscode/keybindings.json" "$HOME/.vscode-server/data/Machine/keybindings.json"

# Zed settings and keymap
link_file "$REPO_DIR/zed/settings.json" "$HOME/.config/zed/settings.json"
link_file "$REPO_DIR/zed/keymap.json"   "$HOME/.config/zed/keymap.json"

# Claude Code global settings
link_file "$REPO_DIR/claude/settings.json" "$HOME/.claude/settings.json"

# Codex CLI global config
link_file "$REPO_DIR/codex/config.toml" "$HOME/.codex/config.toml"

# Ghostty terminal config
link_file "$REPO_DIR/ghostty/config.ghostty" "$HOME/.config/ghostty/config.ghostty"

# Herdr terminal workspace manager config
link_file "$REPO_DIR/herdr/config.toml" "$HOME/.config/herdr/config.toml"

# Herdr agent skill, linked into each coding agent's personal skills directory.
# The SKILL.md file is linked (not the herdr/ directory) so skill discovery that
# stats directory entries still sees a real directory.
link_file "$REPO_DIR/herdr/skill/SKILL.md" "$HOME/.claude/skills/herdr/SKILL.md"
link_file "$REPO_DIR/herdr/skill/SKILL.md" "$HOME/.codex/skills/herdr/SKILL.md"
link_file "$REPO_DIR/herdr/skill/SKILL.md" "$HOME/.pi/agent/skills/herdr/SKILL.md"
link_file "$REPO_DIR/herdr/skill/SKILL.md" "$HOME/.copilot/skills/herdr/SKILL.md"

# --- Herdr skill refresh + agent integrations ---

if command -v herdr &>/dev/null; then
    echo ""
    echo "Refreshing herdr/skill/SKILL.md from the installed herdr binary..."
    herdr --skill > "$REPO_DIR/herdr/skill/SKILL.md"

    # Integrations install lifecycle hooks so Herdr can track agent state and
    # restore native sessions. They write hook scripts outside this repo and add
    # hook entries to claude/settings.json and codex/config.toml (via symlink).
    echo "Installing herdr agent integrations..."
    for agent in claude codex pi copilot; do
        herdr integration install "$agent"
    done
else
    echo ""
    echo "WARNING: herdr not found. Skipping skill refresh and agent integrations."
    echo "  Install: curl -fsSL https://herdr.dev/install.sh | sh"
fi

# --- vim-plug (neovim plugin manager) ---

VIM_PLUG_URL="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
VIM_PLUG_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload"

if [ ! -f "$VIM_PLUG_DIR/plug.vim" ]; then
    echo ""
    echo "Installing vim-plug..."
    mkdir -p "$VIM_PLUG_DIR"
    curl -fLo "$VIM_PLUG_DIR/plug.vim" "$VIM_PLUG_URL"
    echo "vim-plug installed."
else
    echo "vim-plug already installed."
fi

# --- Neovim plugins ---

if command -v nvim &>/dev/null; then
    echo ""
    echo "Installing neovim plugins via :PlugInstall..."
    nvim --headless +PlugInstall +qall 2>/dev/null
    echo "Neovim plugins installed."
    echo "Note: CoC extensions (coc-omnisharp, coc-prettier, coc-pyright) will"
    echo "      auto-install on first neovim launch via g:coc_global_extensions."
else
    echo ""
    echo "WARNING: nvim not found. Skipping plugin installation."
    echo "  Install neovim, then run: nvim +PlugInstall +qall"
fi

# --- TPM (tmux plugin manager) ---

TPM_DIR="$HOME/.tmux/plugins/tpm"

if [ ! -d "$TPM_DIR" ]; then
    echo ""
    echo "Installing TPM (tmux plugin manager)..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
    echo "TPM installed."
else
    echo "TPM already installed."
fi

# TPM install_plugins.sh requires a live tmux session; install manually instead.
echo "Note: To install tmux plugins, open tmux and press prefix + I."

# --- Done ---

echo ""
echo "Done! To use the shell extensions, add this to your ~/.bashrc or ~/.zshrc:"
echo '  if [ -f ~/.shellrc_ext ]; then . ~/.shellrc_ext; fi'
