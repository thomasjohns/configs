#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

# --- Symlinks ---

# Map of source files/dirs (relative to repo) -> symlink targets
declare -A LINKS=(
    ["tmux/.tmux.conf"]="$HOME/.tmux.conf"
    ["nvim"]="$HOME/.config/nvim"
    ["bash/.bashrc_ext"]="$HOME/.bashrc_ext"
)

for src in "${!LINKS[@]}"; do
    target="${LINKS[$src]}"
    source_path="$REPO_DIR/$src"

    # Create parent directory if needed
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
done

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

# Install tmux plugins via TPM
TPM_INSTALL_SCRIPT="$TPM_DIR/scripts/install_plugins.sh"

if [ -x "$TPM_INSTALL_SCRIPT" ]; then
    echo "Installing tmux plugins..."
    "$TPM_INSTALL_SCRIPT"
    echo "Tmux plugins installed."
else
    echo "WARNING: TPM install script not found. Start tmux and press prefix + I to install plugins."
fi

# --- Done ---

echo ""
echo "Done! To use the bashrc extensions, add this to your ~/.bashrc:"
echo '  if [ -f ~/.bashrc_ext ]; then . ~/.bashrc_ext; fi'
