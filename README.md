# tmux-fzf

A tmux plugin for fuzzy finding projects and sessions using [fzf](https://github.com/junegunn/fzf).

## Installation

```tmux
# configure the tmux plugins manager
set -g @plugin "tmux-plugins/tpm"

# official plugins
set -g @plugin 'tmux-contrib/tmux-fzf'
```

## Usage

| Key Binding                                     | Description                   |
| ----------------------------------------------- | ----------------------------- |
| <kbd>Prefix</kbd> + <kbd>f</kbd> + <kbd>p</kbd> | Search and switch to projects |
| <kbd>Prefix</kbd> + <kbd>f</kbd> + <kbd>s</kbd> | Search and switch to sessions |

### Project Picker

- Select a project directory to create or switch to a session
- Press <kbd>Ctrl</kbd>+<kbd>O</kbd> to open the project's GitHub repository in the browser

### Session Picker

- Select a session to switch to it
- Press <kbd>Ctrl</kbd>+<kbd>X</kbd> to kill the highlighted session
- Press <kbd>Space</kbd> for jump mode

### Options

Add these options to your `~/.tmux.conf`:

```tmux
# Set the projects directory (default: ~/Projects)
set -g @fzf-projects-path "~/Projects"

# Change the fzf menu prefix key (default: f)
# Usage: Prefix + <your-key> + p/s
set -g @fzf-prefix-key 'g'

# Change the projects key (default: p)
# Usage: Prefix + f + <your-key>
set -g @fzf-projects-key 'j'

# Change the sessions key (default: s)
# Usage: Prefix + f + <your-key>
set -g @fzf-sessions-key 'k'
```

### Key Binding Design

This plugin uses a **two-key sequence** approach:
1. Press <kbd>Prefix</kbd> + <kbd>f</kbd> to enter the fzf menu
2. Press <kbd>p</kbd> for projects or <kbd>s</kbd> for sessions

**Benefits:**
- No conflicts with default tmux bindings
- Logical grouping of all fzf commands under the "f" namespace
- Easy to expand with more commands in the future
- Works reliably in all terminal emulators
