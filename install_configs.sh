#!/usr/bin/env bash

set -euo pipefail

# Directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIGS_DIR="$SCRIPT_DIR/configs"

# Function to backup and install config
install_config() {
  local src=$1
  local dest=$2
  echo "Installing $src to $dest"
  if [[ -f "$dest" ]]; then
    mv "$dest" "${dest}.bak-$(date +%s)"
  fi
  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
}

# Install tmux config
install_config "$CONFIGS_DIR/tmux.conf" ~/.tmux.conf

# Install zsh config
install_config "$CONFIGS_DIR/zshrc" ~/.zshrc

# Install starship config
install_config "$CONFIGS_DIR/starship.toml" ~/.config/starship.toml

# Install neovim config
install_config "$CONFIGS_DIR/init.vim" ~/.config/nvim/init.vim

# Set default shell to zsh if not already
if [[ "$SHELL" != *zsh ]]; then
  echo "🔀 Setting Zsh as default shell..."
  chsh -s "$(which zsh)"
fi

echo "✅ Configuration files installed successfully!"
