#!/usr/bin/env bash
# Unified Terminal Environment Setup Script
# Installs: tmux, zsh, exa, fzf, zoxide, starship, neovim, ripgrep
# GitHub URL: https://github.com/GPMueller/terminal-setup/raw/main/setup.sh
# Run: curl -sL https://raw.githubusercontent.com/GPMueller/terminal-setup/main/setup.sh | bash

set -euo pipefail

main() {
  detect_platform
  install_dependencies
  setup_configs
  setup_helpme
  set_default_shell
  completion_message
}

detect_platform() {
  case "$(uname -s)" in
    Darwin*) PLATFORM=mac;;
    Linux*)  PLATFORM=linux;;
    *)       echo "Unsupported OS"; exit 1;;
  esac
}

install_dependencies() {
  echo "🛠 Installing dependencies for $PLATFORM..."
  
  if [[ "$PLATFORM" == "mac" ]]; then
    command -v brew >/dev/null || install_homebrew
    brew install tmux zsh exa fzf zoxide neovim ripgrep
    brew tap homebrew/cask-fonts
    brew install --cask font-hack-nerd-font
  else
    sudo apt-get update
    sudo apt-get install -y tmux zsh unzip neovim
    install_linux_tools
  fi

  # Platform-agnostic tools
  curl -sS https://starship.rs/install.sh | sh
  curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
}

install_homebrew() {
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
}

install_linux_tools() {
  # Install exa
  EXA_VERSION="0.10.1"
  curl -LO https://github.com/ogham/exa/releases/download/v$EXA_VERSION/exa-linux-x86_64-v$EXA_VERSION.zip
  unzip -q exa-linux-x86_64-v$EXA_VERSION.zip
  sudo mv bin/exa /usr/local/bin/
  rm -rf exa* bin man
  
  # Install ripgrep
  curl -LO https://github.com/BurntSushi/ripgrep/releases/download/14.1.0/ripgrep_14.1.0_amd64.deb
  sudo dpkg -i ripgrep_14.1.0_amd64.deb
  rm ripgrep_14.1.0_amd64.deb
}

setup_configs() {
  echo "⚙️ Setting up configurations..."
  
  # Create config directories
  mkdir -p ~/.config/{starship,nvim}
  
  # Tmux configuration
  backup_file ~/.tmux.conf
  curl -sL https://gist.githubusercontent.com/yourusername/tmuxconf/raw > ~/.tmux.conf
  
  # Zsh configuration
  backup_file ~/.zshrc
  curl -sL https://gist.githubusercontent.com/yourusername/zshrc/raw > ~/.zshrc
  
  # Starship config
  backup_file ~/.config/starship.toml 
  curl -sL https://gist.githubusercontent.com/yourusername/starship/raw > ~/.config/starship.toml
  
  # Neovim config
  backup_file ~/.config/nvim/init.vim
  curl -sL https://gist.githubusercontent.com/yourusername/nvim/raw > ~/.config/nvim/init.vim
}

setup_helpme() {
  echo "📖 Adding helpme command..."
  cat << 'EOF' >> ~/.zshrc
helpme() {
  echo "CORE SHORTCUTS:"
  echo "  C-a + c     New window"
  echo "  C-a + z     Zoom pane"
  echo "  C-a + [     Scrollback"
  echo "GIT WORKFLOWS:"
  echo "  gw          Stage current file"
  echo "  gp          Push to Gerrit"
  echo "  grb         Interactive rebase"
  echo "BAZEL:"
  echo "  bb          bazel build"
  echo "  bt          bazel test"
  echo "  br          bazel run"
}
EOF
}

backup_file() {
  local file=$1
  if [[ -f "$file" ]]; then
    mv "$file" "${file}.bak-$(date +%s)"
  fi
}

set_default_shell() {
  if [[ "$SHELL" != *zsh ]]; then
    echo "🔀 Setting Zsh as default shell..."
    chsh -s "$(which zsh)"
  fi
}

completion_message() {
  cat << EOF
🎉 Installation complete! Restart your terminal or run:
  
  exec zsh
  
ESSENTIAL NEXT STEPS:
1. Configure your terminal to use Hack Nerd Font
2. In Cursor: disable Ctrl+a shortcut in settings
3. Start tmux session: tmux new -s main

GitHub Repo: https://github.com/yourusername/terminal-setup
EOF
}

main
