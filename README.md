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

You can change the default projects directory by adding the following line to your tmux config:

`set -g @tmux-fzf-projects-path "~/your/path/to/projects"`

