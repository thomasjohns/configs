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
