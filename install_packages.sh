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
  if ! command -v brew >/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
}

# Function to install Linux tools
install_linux_tools() {
  # Install eza (replacement for exa)
  EZA_VERSION="0.18.1"
  EZA_FILE="eza_x86_64-unknown-linux-gnu.tar.gz"
  curl -LO "https://github.com/eza-community/eza/releases/download/v${EZA_VERSION}/${EZA_FILE}"
  tar -xzf "${EZA_FILE}"
  sudo mv eza /usr/local/bin/
  rm -rf eza ${EZA_FILE} LICENSE man completions

  # Install ripgrep
  if ! command -v rg >/dev/null; then
    if sudo apt-get install -y ripgrep; then
      echo "ripgrep installed via apt."
    else
      RG_DEB="ripgrep_14.1.0_amd64.deb"
      curl -LO "https://github.com/BurntSushi/ripgrep/releases/download/14.1.0/${RG_DEB}"
      sudo dpkg -i "${RG_DEB}"
      rm "${RG_DEB}"
    fi
  fi
}

# Function to install Hack Nerd Font
install_fonts() {
  if [[ "$(detect_platform)" == "mac" ]]; then
    install_homebrew
    brew install --cask font-hack-nerd-font
  else
    mkdir -p ~/.local/share/fonts
    cd /tmp
    wget -O Hack.zip "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Hack.zip"
    unzip -o Hack.zip -d HackFont
    cp HackFont/*.ttf ~/.local/share/fonts/
    fc-cache -fv
    rm -rf Hack.zip HackFont
  fi
}

# Main installation function
main() {
  local PLATFORM=$(detect_platform)
  echo "🛠 Installing packages for $PLATFORM..."

  if [[ "$PLATFORM" == "mac" ]]; then
    install_homebrew
    brew install tmux zsh eza fzf zoxide neovim ripgrep coreutils git
    install_fonts
  else
    sudo apt-get update
    sudo apt-get install -y tmux zsh unzip neovim curl wget fontconfig git
    install_linux_tools
    install_fonts
  fi

  # Platform-agnostic tools
  curl -sS https://starship.rs/install.sh | sh -s -- --yes
  curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

  echo "✅ Package installation complete!"
}

main
