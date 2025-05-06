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
  echo "📦 Installing Homebrew..."
  if ! command -v brew >/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  echo "✅ Homebrew installation complete"
}

# Function to install Oh My Zsh
install_ohmyzsh() {
  echo "🐚 Installing Oh My Zsh..."
  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi
  echo "✅ Oh My Zsh installation complete"

  # Install additional plugins
  echo "📦 Installing Oh My Zsh plugins..."
  if [[ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  fi
  if [[ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
  fi
  echo "✅ Oh My Zsh plugins installed"
}

# Function to install Linux tools
install_linux_tools() {
  echo "🔧 Installing Linux tools..."
  # Install eza (replacement for exa)
  echo "  📦 Installing eza..."
  EZA_VERSION="0.18.1"
  EZA_FILE="eza_x86_64-unknown-linux-gnu.tar.gz"
  curl -LO "https://github.com/eza-community/eza/releases/download/v${EZA_VERSION}/${EZA_FILE}"
  tar -xzf "${EZA_FILE}"
  sudo mv eza /usr/local/bin/
  rm -rf eza ${EZA_FILE} LICENSE man completions
  echo "  ✅ eza installed"

  # Install ripgrep
  echo "  📦 Installing ripgrep..."
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
  fi
  echo "✅ Linux tools installation complete"
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

# Main installation function
main() {
  local PLATFORM=$(detect_platform)
  echo "🚀 Starting package installation for $PLATFORM..."

  if [[ "$PLATFORM" == "mac" ]]; then
    install_homebrew
    echo "📦 Installing core packages..."
    brew install tmux eza fzf neovim ripgrep coreutils git
    echo "✅ Core packages installed"
  else
    echo "📦 Updating package lists..."
    sudo apt-get update
    echo "📦 Installing core packages..."
    sudo apt-get install -y tmux unzip neovim curl wget fontconfig git build-essential pkg-config libssl-dev
    echo "✅ Core packages installed"
    install_linux_tools
  fi

  # Install Oh My Zsh
  # install_ohmyzsh

  # Platform-agnostic tools
  echo "🌟 Installing Starship prompt..."
  curl -sS https://starship.rs/install.sh | sh -s -- --yes
  echo "✅ Starship installed"

  echo "📍 Installing Zoxide..."
  curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
  echo "✅ Zoxide installed"

  # Install Nushell
  install_nushell

  # Install Tmux Plugin Manager (TPM)
  echo "📦 Installing Tmux Plugin Manager..."
  mkdir -p ~/.config/tmux/plugins
  git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
  echo "✅ TPM installed"

  # Install fonts
  echo "  🎨 Installing Hack Nerd Font..."
  if [[ "$(detect_platform)" == "mac" ]]; then
    install_homebrew
    echo "  📦 Installing font via Homebrew..."
    brew install --cask font-hack-nerd-font
    echo "  ✅ Font installed via Homebrew"
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

    echo "  ✅ Font installation complete"
  fi

  echo "✨ All package installations complete!"
}

main
