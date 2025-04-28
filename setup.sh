#!/usr/bin/env bash
# Unified Terminal Environment Setup Script
# Installs: tmux, zsh, eza, fzf, zoxide, starship, neovim, ripgrep
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
    brew install tmux zsh eza fzf zoxide neovim ripgrep coreutils git
    brew install --cask font-hack-nerd-font
  else
    sudo apt-get update
    sudo apt-get install -y tmux zsh unzip neovim curl wget fontconfig git
    install_linux_tools
    # Install Hack Nerd Font for Linux
    mkdir -p ~/.local/share/fonts
    wget -O ~/.local/share/fonts/HackNerdFont-Regular.ttf https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/HackNerdFont-Regular.ttf
    fc-cache -fv
  fi

  # Platform-agnostic tools
  curl -sS https://starship.rs/install.sh | sh -s -- --yes
  curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
}

install_homebrew() {
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
}

install_linux_tools() {
  # Install eza (replacement for exa)
  EZA_VERSION="0.18.1"
  curl -LO https://github.com/eza-community/eza/releases/download/v${EZA_VERSION}/eza_${EZA_VERSION}_linux-x86_64.tar.gz
  tar -xzf eza_${EZA_VERSION}_linux-x86_64.tar.gz
  sudo mv eza /usr/local/bin/
  rm -rf eza_* LICENSE man completions

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
  curl -sL https://gist.githubusercontent.com/GPMueller/tmuxconf/raw > ~/.tmux.conf

  # Zsh configuration (with ls alias for icons)
  backup_file ~/.zshrc
  cat << 'EOF' > ~/.zshrc
# Zsh config for modern terminal
# Enable completion, history, and starship prompt
autoload -Uz compinit && compinit
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt inc_append_history
setopt share_history
setopt hist_ignore_dups
setopt hist_reduce_blanks
setopt auto_cd
setopt correct

# Show icons by default in ls
alias ls='eza --icons'

# Starship prompt
if command -v starship >/dev/null; then
  eval "$(starship init zsh)"
fi

# fzf keybindings and completion
if [ -f ~/.fzf.zsh ]; then
  source ~/.fzf.zsh
fi

# zoxide init
if command -v zoxide >/dev/null; then
  eval "$(zoxide init zsh)"
fi

# ... any other zsh config ...
EOF

  # Starship config
  backup_file ~/.config/starship.toml
  cat << 'EOF' > ~/.config/starship.toml
# Minimal Starship prompt config
add_newline = false
[character]
success_symbol = "[➜](bold green) "
error_symbol = "[✗](bold red) "
[git_branch]
disabled = false
[git_status]
disabled = false
EOF

  # Minimal Neovim config
  backup_file ~/.config/nvim/init.vim
  cat << 'EOF' > ~/.config/nvim/init.vim
set number
syntax on
set mouse=a
set clipboard=unnamedplus
set tabstop=4
set shiftwidth=4
set expandtab
set smartindent
set autoindent
set background=dark
EOF

  # Set git default editor to nvim
  if command -v nvim >/dev/null; then
    git config --global core.editor "nvim"
  fi
}

setup_helpme() {
  echo "📖 Adding helpme command..."
  cat << 'EOF' >> ~/.zshrc
helpme() {
  echo "\n========= TERMINAL QUICK REFERENCE ========="
  echo "\nTMUX (Terminal Multiplexer):"
  echo "  tmux new -s <name>         Start new session"
  echo "  tmux attach -t <name>      Attach to session"
  echo "  tmux ls                    List sessions"
  echo "  tmux kill-session -t <name> Kill session"
  echo "  Ctrl+b c                   New window"
  echo "  Ctrl+b ,                   Rename window"
  echo "  Ctrl+b n/p                 Next/Prev window"
  echo "  Ctrl+b %                   Split pane vertically"
  echo "  Ctrl+b '                   Split pane horizontally"
  echo "  Ctrl+b o                   Switch pane"
  echo "  Ctrl+b x                   Kill pane"
  echo "  Ctrl+b z                   Zoom pane"
  echo "  Ctrl+b [                   Enter copy mode (scrollback)"
  echo "  Ctrl+b d                   Detach from session"
  echo "\nZSH (Shell):"
  echo "  Ctrl+R                     Fuzzy search command history"
  echo "  Tab                        Autocomplete commands/files"
  echo "  cd -                       Go to previous directory"
  echo "  !!                         Repeat last command"
  echo "  Ctrl+A/E                   Start/End of line"
  echo "  Ctrl+U/K                   Delete to start/end of line"
  echo "\nFZF (Fuzzy Finder):"
  echo "  fzf                        Fuzzy find files interactively"
  echo "  Ctrl+R                     Fuzzy search shell history"
  echo "  fzf --preview 'bat --style=numbers --color=always {}'  Preview files (if bat installed)"
  echo "\nZOXIDE (Directory Jumper):"
  echo "  z <dir>                    Jump to directory (frecency-based)"
  echo "  z                          List most used directories"
  echo "\nEZA (Modern ls):"
  echo "  eza                        List files (modern replacement for ls)"
  echo "  eza -l                     Long format"
  echo "  eza --tree                 Tree view"
  echo "  eza --icons                Show icons (with Nerd Font)"
  echo "\nRIPGREP (Fast Search):"
  echo "  rg <pattern> <dir>         Recursively search for pattern"
  echo "  rg -t py <pattern>         Search only Python files"
  echo "\nSTARSHIP (Prompt):"
  echo "  starship                   Show prompt version"
  echo "  starship preset <name>     Try a different prompt style"
  echo "  starship config            Edit config (~/.config/starship.toml)"
  echo "\nNEOVIM (Modern Vim):"
  echo "  nvim <file>                Open file in Neovim"
  echo "  :e <file>                  Edit file"
  echo "  :w / :q / :wq              Write/Quit/Write+Quit"
  echo "  :Explore                   File explorer"
  echo "  :help <topic>              Open help"
  echo "  Config: ~/.config/nvim/init.vim"
  echo "\nSSH + TMUX (Remote Workflows):"
  echo "  ssh <host>                 Connect to remote machine"
  echo "  tmux new -s <name>         Start tmux on remote"
  echo "  (If SSH drops, reconnect and run: tmux attach -t <name>)"
  echo "\nCONFIG RELOAD:"
  echo "  source ~/.zshrc            Reload shell config"
  echo "  tmux source-file ~/.tmux.conf Reload tmux config"
  echo "\nFONTS:"
  echo "  Use a Nerd Font in your terminal for best icon support."
  echo "\nMORE HELP:"
  echo "  man <command>              Show manual for command"
  echo "  <command> --help           Show help for command"
  echo "  https://github.com/GPMueller/terminal-setup"
  echo "==============================================="
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
1. Set your terminal font to "Hack Nerd Font":
   - macOS Terminal.app: Preferences > Profiles > Text > Change Font > select "Hack Nerd Font"
   - Cursor (VS Code): Settings (Cmd+,) > Features > Terminal > Integrated: Font Family > set to 'Hack Nerd Font'
   - Linux Terminal: Preferences > Text/Font > select "Hack Nerd Font" (may vary by terminal)
2. In Cursor: disable Ctrl+a shortcut in settings (to use tmux's default prefix)
3. Start tmux session: tmux new -s main
4. If you just installed zsh as your default shell, log out and back in (or restart your terminal) for the change to take effect.

GitHub Repo: https://github.com/GPMueller/terminal-setup
EOF
}

main
