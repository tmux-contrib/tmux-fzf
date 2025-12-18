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

| Key Binding   | Description                    |
|---------------|--------------------------------|
| `prefix` + <kbd>P</kbd> | Search and switch to projects  |
| `prefix` + <kbd>S</kbd> | Search and switch to sessions  |

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
set -g @tmux-fzf-projects-path "~/Projects"

# Show only git repositories (default: true)
set -g @tmux-fzf-projects-git-only "true"
```
