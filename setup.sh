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

  # Show completion message
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
