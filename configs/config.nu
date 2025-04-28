# Enhanced Nushell configuration with Bazel/Git optimizations
$env.PATH = ($env.PATH | prepend ($nu.home-path | path join ".local" "bin"))
alias z = zoxide

# Disable default welcome message
$env.config.show_banner = false

# History configuration
$env.config.history = {
  max_size: 50000
  sync_on_enter: true
}

# Keybindings for fzf integration
$env.config.keybindings = [
  {
    name: fzf_file_search
    modifier: control
    keycode: char_f
    mode: [emacs, vi_normal, vi_insert]
    event: { send: ExecuteHostCommand, cmd: "fzf-file-search" }
  }
]

# Help command for terminal shortcuts
def helpme [] {
  print (echo "TERMINAL SHORTCUTS:
  Ctrl+F       Fuzzy file search with fzf
  Alt+Arrows   Navigate tmux panes
  Ctrl+Space   Auto-completion
  Ctrl+B       Tmux prefix key

FILE NAVIGATION:
  z <dir>      Jump to directory with zoxide
  z -          Jump to previous directory
  zi           Interactive directory selection
  ls           List files with icons and git status
  lt           Tree view of current directory

TMUX COMMANDS:
  Ctrl+B c     Create new window
  Ctrl+B n     Next window
  Ctrl+B p     Previous window
  Ctrl+B %     Split pane vertically
  Ctrl+B \"     Split pane horizontally
  Ctrl+B [     Enter copy mode
  Ctrl+B d     Detach from session
  Ctrl+B &     Kill current window
  Ctrl+B x     Kill current pane

FZF USAGE:
  Ctrl+T       Search files in current directory
  Ctrl+R       Search command history
  Alt+C        Search and cd into directory
  **<TAB>      Trigger fuzzy completion")
}

# fzf integration for advanced search
def fzf-file-search [] {
  let selected = (ls | get name | fzf --height 40% --reverse --border)
  if $selected != "" {
    cd $selected
  }
}
