#!/usr/bin/env bash

set -euo pipefail

# Directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_CONFIGS_DIR="$SCRIPT_DIR/configs"

# Detect operating system
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
    CACHE_DIR="$HOME/Library/Caches"
    TARGET_CONFIGS_DIR="$HOME/Library/Application Support"
else
    OS="linux"
    CACHE_DIR="$HOME/.cache"
    TARGET_CONFIGS_DIR="$HOME/.config"
fi

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
mkdir -p "$CACHE_DIR"/{starship,zoxide,fzf}
echo "✅ Cache directories created"

echo "🔧 Installing configuration files..."
# Install tmux config
echo "📦 Installing tmux configuration..."
install_config "$SOURCE_CONFIGS_DIR/tmux.conf" ~/.tmux.conf

# Install nushell config
echo "📦 Installing nushell configuration..."
install_config "$SOURCE_CONFIGS_DIR/config.nu" "$TARGET_CONFIGS_DIR/nushell/config.nu"
install_config "$SOURCE_CONFIGS_DIR/env.nu" "$TARGET_CONFIGS_DIR/nushell/env.nu"
mkdir -p "$TARGET_CONFIGS_DIR/nushell/vendor/autoload"
echo "$TARGET_CONFIGS_DIR/nushell/vendor/autoload"
touch "$TARGET_CONFIGS_DIR/nushell/vendor/autoload/starship.nu"
ls "$TARGET_CONFIGS_DIR/nushell/vendor/autoload"

# Install starship config
echo "📦 Installing starship configuration..."
install_config "$SOURCE_CONFIGS_DIR/starship.toml" "$TARGET_CONFIGS_DIR/starship.toml"

# Install neovim config
echo "📦 Installing neovim configuration..."
install_config "$SOURCE_CONFIGS_DIR/init.vim" "$TARGET_CONFIGS_DIR/nvim/init.vim"

# Install shell config based on OS
echo "📦 Installing zsh configuration..."
install_config "$SOURCE_CONFIGS_DIR/zshrc" ~/.zshrc
# echo "📦 Installing bash configuration..."
# install_config "$SOURCE_CONFIGS_DIR/.bashrc" ~/.bashrc

echo "✨ All configuration files installed successfully!"
