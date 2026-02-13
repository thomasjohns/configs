#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

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

echo ""
echo "Done! To use the bashrc extensions, add this to your ~/.bashrc:"
echo '  if [ -f ~/.bashrc_ext ]; then . ~/.bashrc_ext; fi'
