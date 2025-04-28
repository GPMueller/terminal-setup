#!/usr/bin/env bash

set -euo pipefail

# Directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIGS_DIR="$SCRIPT_DIR/configs"

# Function to backup and install config
install_config() {
  local src=$1
  local dest=$2
  echo "  📝 Installing $src to $dest"
  if [[ -f "$dest" ]]; then
    echo "  📦 Backing up existing config..."
    mv "$dest" "${dest}.bak-$(date +%s)"
  fi
  echo "  📁 Creating directory structure..."
  mkdir -p "$(dirname "$dest")"
  echo "  ✍️  Copying config file..."
  cp "$src" "$dest"
  echo "  ✅ Config installation complete"
}

echo "📁 Creating cache directories..."
# Create necessary cache directories
mkdir -p ~/.cache/{starship,zoxide,fzf}
mkdir -p ~/.config/nushell
echo "✅ Cache directories created"

echo "🔧 Installing configuration files..."
# Install tmux config
echo "📦 Installing tmux configuration..."
install_config "$CONFIGS_DIR/tmux.conf" ~/.tmux.conf

# Install nushell config
echo "📦 Installing nushell configuration..."
install_config "$CONFIGS_DIR/config.nu" ~/.config/nushell/config.nu
install_config "$CONFIGS_DIR/env.nu" ~/.config/nushell/env.nu

# Install starship config
echo "📦 Installing starship configuration..."
install_config "$CONFIGS_DIR/starship.toml" ~/.config/starship.toml

# Install neovim config
echo "📦 Installing neovim configuration..."
install_config "$CONFIGS_DIR/init.vim" ~/.config/nvim/init.vim

# Install zsh config
# install_config "$CONFIGS_DIR/zshrc" ~/.zshrc

# Install bashrc
# echo "📦 Installing bashrc configuration..."
#install_config "$CONFIGS_DIR/.bashrc" ~/.bashrc

# Set default shell to nushell if not already
# if [[ "$SHELL" != *nu ]]; then
#   echo "🔀 Setting Nushell as default shell..."
#   which nu > /dev/null 2>&1 || { echo "❌ Nushell (nu) not found in PATH"; exit 1; }
#   echo "  📝 Changing default shell..."
#   chsh -s "$(which nu)"
#   echo "  ✅ Default shell changed to Nushell"
# fi

echo "✨ All configuration files installed successfully!"
