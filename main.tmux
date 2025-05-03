#!/bin/bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

tmux bind C-p run-shell "$CURRENT_DIR/scripts/fzf-tmux-project.sh"
tmux bind C-s run-shell "$CURRENT_DIR/scripts/fzf-tmux-session.sh"
