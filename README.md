# tmux-fzf

A fzf plugin for tmux

## Installation

This is a plugin for [tmux plugin
manager](https://github.com/tmux-plugins/tpm). You can install it by adding the
following line in your tmux config.

```shell
set -g @plugin 'tmux-contrib/tmux-fzf'
```

## Getting Started

You can use the following key bindings to use the plugin:

- `<prefix>-P` to search for projects
- `<prefix>-S` to search for sessions

## Configuration

You can customize the plugin behavior with the following options in your tmux config:

### Projects Directory

Change the default projects directory:

```shell
set -g @tmux-fzf-projects-path "~/your/path/to/projects"
```

### Git Repositories Only

By default, the project search only shows directories that contain a `.git` subdirectory (i.e., git repositories). To show all directories instead:

```shell
set -g @tmux-fzf-projects-git-only "false"
```

