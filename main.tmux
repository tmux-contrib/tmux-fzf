#!/bin/bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

tmux bind C-p run-shell "$SHELL -lic $CURRENT_DIR/scripts/tmux-fzf-project.sh"
tmux bind C-s run-shell "$SHELL -lic $CURRENT_DIR/scripts/tmux-fzf-session.sh"
