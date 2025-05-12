#!/usr/bin/env bash
# To run this in a single command:
# cd $(mktemp -d) && curl -sL https://github.com/GPMueller/terminal-setup/archive/refs/heads/main.tar.gz | tar xz && cd terminal-setup-main && ./setup.sh && cd .. && rm -rf "$(pwd)"

set -euo pipefail

# Directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

main() {
  # Install all required packages
  "$SCRIPT_DIR/install_packages.sh"

  # Install all configuration files
  "$SCRIPT_DIR/install_configs.sh"

  # Set default shell to zsh if not already
  if [[ "$SHELL" != *zsh ]]; then
    echo "🔀 Setting Zsh as default shell..."
    which zsh > /dev/null 2>&1 || { echo "❌ Zsh not found in PATH"; exit 1; }
    echo "  📝 Changing default shell..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
      # Check if we need to change the shell
      current_shell=$(dscl . -read /Users/$USER UserShell | cut -d' ' -f2)
      if [[ "$current_shell" != "$(which zsh)" ]]; then
        sudo dscl . -change /Users/$USER UserShell "$current_shell" "$(which zsh)"
        echo "  ✅ Default shell changed to Zsh"
      else
        echo "  ℹ️  Zsh is already the default shell"
      fi
    else
      chsh -s "$(which zsh)"
      echo "  ✅ Default shell changed to Zsh"
    fi
  else
    echo "ℹ️  Zsh is already the default shell"
  fi

  # Configure git to use nvim as editor
  current_editor=$(git config --global core.editor || echo "")
  if [[ "$current_editor" != "nvim" ]]; then
    echo "📦 Configuring git to use nvim as editor..."
    git config --global core.editor "nvim"
    echo "✅ Git editor configured"
  else
    echo "ℹ️  Git is already configured to use nvim"
  fi

  # Show completion message
  cat << EOF
🎉 Installation/Update complete! Restart your terminal or run:

  exec zsh

ESSENTIAL NEXT STEPS:
 1. Set your terminal font to "Hack Nerd Font":
    - macOS Terminal.app: Preferences > Profiles > Text > Change Font > select "Hack Nerd Font"
    - Cursor (VS Code): Settings (Cmd+,) > Features > Terminal > Integrated: Font Family > set to 'Hack Nerd Font'
    - Linux Terminal: Preferences > Text/Font > select "Hack Nerd Font" (may vary by terminal)
 2. In Cursor: disable Ctrl+a shortcut in settings (to use tmux's default prefix)
 3. If you just installed a new default shell, log out and back in (or restart your terminal) for the change to take effect.

GitHub Repo: https://github.com/GPMueller/terminal-setup
EOF
}

main
