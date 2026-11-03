# tmux-fzf

> Blazing-fast project and session switching for tmux, powered by [fzf](https://github.com/junegunn/fzf).

[![CI](https://github.com/tmux-contrib/tmux-fzf/actions/workflows/ci.yml/badge.svg)](https://github.com/tmux-contrib/tmux-fzf/actions/workflows/ci.yml) [![Release](https://img.shields.io/github/v/release/tmux-contrib/tmux-fzf)](https://github.com/tmux-contrib/tmux-fzf/releases) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## Dependencies

### Required

- [fzf](https://github.com/junegunn/fzf)
- [fd](https://github.com/sharkdp/fd)

### Optional

- [gh](https://cli.github.com/) - Enables opening GitHub repositories from the picker
- [gum](https://github.com/charmbracelet/gum) - Highlights upterm sessions in the session picker
- [tmux-upterm](https://github.com/tmux-contrib/tmux-upterm) - Enables opening projects in upterm
- [vagrant](https://www.vagrantup.com/) - Enables the vagrant box picker

## Installation

Add this plugin to your `~/.tmux.conf`:

```tmux
set -g @plugin 'tmux-contrib/tmux-fzf'
```

And install it by running `<prefix> + I`.

## Usage

| Key Binding                                     | Description                   |
| ----------------------------------------------- | ----------------------------- |
| <kbd>Prefix</kbd> + <kbd>f</kbd> + <kbd>p</kbd> | Search and switch to projects |
| <kbd>Prefix</kbd> + <kbd>f</kbd> + <kbd>s</kbd> | Search and switch to sessions |
| <kbd>Prefix</kbd> + <kbd>f</kbd> + <kbd>v</kbd> | Search and open vagrant boxes |

### Project Picker

- Select a project directory to create or switch to a session
- Press <kbd>Ctrl</kbd>+<kbd>O</kbd> to open the project's GitHub repository in the browser
- Press <kbd>Ctrl</kbd>+<kbd>T</kbd> to open the project in upterm (if available)

### Session Picker

- Select a session to switch to it
- Press <kbd>Ctrl</kbd>+<kbd>O</kbd> to open the session's GitHub repository in the browser
- Press <kbd>Ctrl</kbd>+<kbd>X</kbd> to kill the highlighted session
- Press <kbd>Space</kbd> for jump mode

### Vagrant Picker

Lists the boxes known to `vagrant global-status` (requires [vagrant](https://www.vagrantup.com/)).

- Select a box to create or switch to its `vagrant/<directory>/<name>` session running `vagrant ssh`
- Boxes that are not running are started with `vagrant up` first
- Press <kbd>Ctrl</kbd>+<kbd>W</kbd> to open the box in a new window of the current session instead
- Press <kbd>Ctrl</kbd>+<kbd>X</kbd> to halt the highlighted box
- Press <kbd>Ctrl</kbd>+<kbd>P</kbd> to prune stale entries from vagrant's cached box list

The session closes when you exit the `vagrant ssh` shell.

### Session Naming

Sessions are named from the project directory path using the `workspace/project` convention:

- `/home/user/Projects/github.com/org/repo` → `org/repo`
- Dots in names are replaced with underscores for tmux compatibility

Vagrant sessions use `vagrant/<directory>/<name>`, for example `vagrant/my_app/default`. If two boxes would share a name, the machine id is appended.

### Key Binding Design

This plugin uses a **two-key sequence** approach:
1. Press <kbd>Prefix</kbd> + <kbd>f</kbd> to enter the fzf menu
2. Press <kbd>p</kbd> for projects, <kbd>s</kbd> for sessions or <kbd>v</kbd> for vagrant boxes

**Benefits:**
- No conflicts with default tmux bindings
- Logical grouping of all fzf commands under the "f" namespace
- Easy to expand with more commands in the future
- Works reliably in all terminal emulators

## Commands

You can call the `scripts/tmux_fzf.sh` script directly:

```sh
# Print plugin version
/path/to/tmux-fzf/scripts/tmux_fzf.sh --version

# Return configured projects directory
/path/to/tmux-fzf/scripts/tmux_fzf.sh project-dir

# List project directories (full paths)
/path/to/tmux-fzf/scripts/tmux_fzf.sh project-list

# List sessions with styling
/path/to/tmux-fzf/scripts/tmux_fzf.sh session-list

# Open GitHub repository in browser (accepts path or session name)
/path/to/tmux-fzf/scripts/tmux_fzf.sh github-open <path|session>

# Open project in upterm
/path/to/tmux-fzf/scripts/tmux_fzf.sh upterm-open <path>

# List vagrant boxes (id, name, state, provider, directory)
/path/to/tmux-fzf/scripts/tmux_fzf.sh vagrant-list

# Halt a vagrant box (accepts a line from vagrant-list)
/path/to/tmux-fzf/scripts/tmux_fzf.sh vagrant-halt "<line>"

# Prune stale entries from vagrant's box list
/path/to/tmux-fzf/scripts/tmux_fzf.sh vagrant-prune
```

### Debugging

Enable trace output with the `DEBUG` environment variable:

```sh
DEBUG=1 /path/to/tmux-fzf/scripts/tmux_fzf.sh --version
```

## Configuration

Add these options to your `~/.tmux.conf`:

```tmux
# Set the projects directory (default: ~/Projects)
set -g @fzf-projects-path "~/Projects"

# Change the fzf menu prefix key (default: f)
# Usage: Prefix + <your-key> + p/s/v
set -g @fzf-prefix-key 'g'

# Change the projects key (default: p)
# Usage: Prefix + f + <your-key>
set -g @fzf-projects-key 'j'

# Change the sessions key (default: s)
# Usage: Prefix + f + <your-key>
set -g @fzf-sessions-key 'k'

# Change the vagrant key (default: v)
# Usage: Prefix + f + <your-key>
set -g @fzf-vagrant-key 'l'
```

## Development

### Prerequisites

Install dependencies using [Nix](https://nixos.org/):

```sh
nix develop
```

Or install manually: `bash`, `tmux`, `fzf`, `fd`, `bats`

### Running Tests

```sh
bats tests/
```

## License

MIT
