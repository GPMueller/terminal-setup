# Enhanced Nushell configuration with Bazel/Git optimizations
$env.PATH = ($env.PATH | prepend ($nu.home-path | path join ".local" "bin"))
alias z = zoxide
# alias cd = zoxide

# Modern file listing with eza
# alias ls = eza --icons --git --group-directories-first --time-style=long-iso
# alias lt = eza --tree --level=2 --icons

# fzf integration for advanced search
def fzf-file-search [] {
  let selected = (ls | get name | fzf --height 40% --reverse --border)
  if $selected != "" {
    cd $selected
  }
}

# Disable default welcome message
$env.config.show_banner = false

# Helper function to create a content line
def content [text] {
  let padded = ($text | fill --alignment l --character ' ' --width ((term size | get columns) - 2))
  $"║($padded)║"
}
# Helper function to create a border line
def border [left char right] {
  $"($left)($char | fill --character $char --width ((term size | get columns) - 2))($right)"
}

# Dynamic welcome message
def welcome [] {
    let os = (sys host).name
    let kernel = (sys host).kernel_version
    let memory = ((sys mem).total / 1024 / 1024 / 1024 | into string) + "GB"
    let uptime_record = (sys host).uptime | into record
    let uptime =  (((sys host).uptime | into record).week | into string) + "wk " + (((sys host).uptime | into record).day | into string) + "d " + (((sys host).uptime | into record).hour | into string) + ":" + (((sys host).uptime | into record).minute | into string)
    # let disk = (df -h / | get "Use%" | get 0)
    let disk_available = df -h / | into string | lines | get 1 | split row --regex '\s+' | get 1
    let disk_used = df -h / | into string | lines | get 1 | split row --regex '\s+' | get 2
    let disk_used_percentage = df -h / | into string | lines | get 1 | split row --regex '\s+' | get 4

    # Get tmux sessions
    let tmux_sessions = (tmux list-sessions | into string | lines)
    # | each {|line|
    #     let parts = ($line | split row ":")
    #     let name = ($parts | get 0)
    #     let windows = ($parts | get 1 | str trim)
    #     $"($name) ($windows)"
    # })
    let has_tmux = ($tmux_sessions | length) > 0

    let colors = ["red", "green", "yellow", "blue", "magenta", "cyan"]
    let random_color = ($colors | get (random int 0..5))

    print $"(ansi $random_color)"
    print (border '╔' '═' '╗')
    print (content '  LETS GOOOOOO !!')
    print (border '╠' '═' '╣')
    print (content '  System Information')
    print (content $'    OS: ($os)')
    print (content $'    Kernel: ($kernel)')
    print (content $'    Memory: ($memory)')
    print (content $'    Disk Usage: ($disk_used) / ($disk_available) = ($disk_used_percentage)')
    print (content $'    Uptime: ($uptime)')

    if $has_tmux {
        print (border '╠' '═' '╣')
        print (content '  Active Tmux Sessions:')
        $tmux_sessions | each {|session|
            print (content $'    • ($session)')
        }
    }

    print (border '╠' '═' '╣')
    print (content '  Quick Tips:')
    print (content "    • Type 'helpme' for a list of available commands")
    print (content "    • Use 'z' for quick directory navigation")
    print (content "    • Press Ctrl+F for fuzzy file search")
    print (content "    • Use 'tmux new -s name' to create a new session")
    print (content "    • Press Ctrl+B for tmux commands")
    print (border '╚' '═' '╝')
    print $"(ansi reset)\n"
}

# Run welcome message at startup
welcome

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
