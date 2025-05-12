#!/usr/bin/env bash

set -euo pipefail

# Directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to detect platform
detect_platform() {
  case "$(uname -s)" in
    Darwin*) echo "mac";;
    Linux*)  echo "linux";;
    *)       echo "Unsupported OS"; exit 1;;
  esac
}

# Function to install Homebrew
install_homebrew() {
  echo "📦 Installing/Updating Homebrew..."
  if ! command -v brew >/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    brew update
  fi
  echo "✅ Homebrew installation/update complete"
}

# Function to install Oh My Zsh
install_ohmyzsh() {
  echo "🐚 Installing/Updating Oh My Zsh..."
  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  else
    # Update existing installation
    cd "$HOME/.oh-my-zsh"
    git pull
    cd - > /dev/null
  fi
  echo "✅ Oh My Zsh installation/update complete"

  # Install/Update additional plugins
  echo "📦 Installing/Updating Oh My Zsh plugins..."
  local plugins_dir="$HOME/.oh-my-zsh/custom/plugins"
  mkdir -p "$plugins_dir"

  # zsh-autosuggestions
  if [[ ! -d "$plugins_dir/zsh-autosuggestions" ]]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$plugins_dir/zsh-autosuggestions"
  else
    cd "$plugins_dir/zsh-autosuggestions"
    git pull
    cd - > /dev/null
  fi

  # zsh-syntax-highlighting
  if [[ ! -d "$plugins_dir/zsh-syntax-highlighting" ]]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$plugins_dir/zsh-syntax-highlighting"
  else
    cd "$plugins_dir/zsh-syntax-highlighting"
    git pull
    cd - > /dev/null
  fi
  echo "✅ Oh My Zsh plugins installed/updated"
}

# Function to install Linux tools
install_linux_tools() {
  echo "🔧 Installing/Updating Linux tools..."
  # Install eza (replacement for exa)
  echo "  📦 Installing/Updating eza..."
  EZA_VERSION="0.18.1"
  EZA_FILE="eza_x86_64-unknown-linux-gnu.tar.gz"
  curl -LO "https://github.com/eza-community/eza/releases/download/v${EZA_VERSION}/${EZA_FILE}"
  tar -xzf "${EZA_FILE}"
  sudo mv eza /usr/local/bin/
  rm -rf eza ${EZA_FILE} LICENSE man completions
  echo "  ✅ eza installed/updated"

  # Install ripgrep
  echo "  📦 Installing/Updating ripgrep..."
  if ! command -v rg >/dev/null; then
    if sudo apt-get install -y ripgrep; then
      echo "  ✅ ripgrep installed via apt"
    else
      RG_DEB="ripgrep_14.1.0_amd64.deb"
      curl -LO "https://github.com/BurntSushi/ripgrep/releases/download/14.1.0/${RG_DEB}"
      sudo dpkg -i "${RG_DEB}"
      rm "${RG_DEB}"
      echo "  ✅ ripgrep installed via deb package"
    fi
  else
    sudo apt-get upgrade -y ripgrep
    echo "  ✅ ripgrep updated"
  fi
  echo "✅ Linux tools installation/update complete"
}

# Function to install Nushell
install_nushell() {
  echo "🐚 Installing Nushell..."
  if [[ "$(detect_platform)" == "mac" ]]; then
    brew install nushell
  else
    # Install Nushell on Linux
    echo "  📦 Installing Nushell via apt..."
    curl -fsSL https://apt.fury.io/nushell/gpg.key | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/fury-nushell.gpg
    echo "deb https://apt.fury.io/nushell/ /" | sudo tee /etc/apt/sources.list.d/fury.list
    sudo apt update
    sudo apt install -y nushell
  fi
  echo "✅ Nushell installation complete"
}

# Function to install Tmux Plugin Manager
install_tpm() {
  echo "📦 Installing/Updating Tmux Plugin Manager..."
  local tpm_dir="$HOME/.config/tmux/plugins/tpm"
  if [[ ! -d "$tpm_dir" ]]; then
    mkdir -p "$(dirname "$tpm_dir")"
    git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
  else
    cd "$tpm_dir"
    git pull
    cd - > /dev/null
  fi
  echo "✅ TPM installed/updated"
}

# Main installation function
main() {
  local PLATFORM=$(detect_platform)
  echo "🚀 Starting package installation/update for $PLATFORM..."

  if [[ "$PLATFORM" == "mac" ]]; then
    install_homebrew
    echo "📦 Installing/Updating core packages..."
    brew install tmux eza fzf neovim ripgrep coreutils git figlet lolcat || brew upgrade tmux eza fzf neovim ripgrep coreutils git figlet lolcat
    echo "✅ Core packages installed/updated"
  else
    echo "📦 Updating package lists..."
    sudo apt-get update
    echo "📦 Installing/Updating core packages..."
    sudo apt-get install -y tmux unzip neovim curl wget fontconfig git build-essential pkg-config libssl-dev figlet lolcat
    echo "✅ Core packages installed/updated"
    install_linux_tools
  fi

  # Install Oh My Zsh
  install_ohmyzsh

  # Platform-agnostic tools
  echo "🌟 Installing/Updating Starship prompt..."
  curl -sS https://starship.rs/install.sh | sh -s -- --yes
  echo "✅ Starship installed/updated"

  echo "📍 Installing/Updating Zoxide..."
  curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
  echo "✅ Zoxide installed/updated"

  # Install Nushell
  install_nushell

  # Install Tmux Plugin Manager
  install_tpm

  # Install fonts
  echo "  🎨 Installing/Updating Hack Nerd Font..."
  if [[ "$PLATFORM" == "mac" ]]; then
    install_homebrew
    echo "  📦 Installing/Updating font via Homebrew..."
    brew install --cask font-hack-nerd-font || brew upgrade --cask font-hack-nerd-font
    echo "  ✅ Font installed/updated via Homebrew"
  else
    echo "  📁 Creating fonts directory..."
    mkdir -p ~/.local/share/fonts

    echo "  📦 Downloading Hack Nerd Font..."
    cd /tmp
    wget -O Hack.zip "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Hack.zip"

    echo "  📂 Extracting font files..."
    unzip -o Hack.zip -d HackFont

    echo "  📝 Installing font files..."
    cp HackFont/*.ttf ~/.local/share/fonts/

    echo "  🔄 Updating font cache..."
    fc-cache -fv

    echo "  🧹 Cleaning up temporary files..."
    rm -rf Hack.zip HackFont
    cd - > /dev/null

    echo "  ✅ Font installation/update complete"
  fi

  echo "✨ All package installations/updates complete!"
}

main
