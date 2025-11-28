#!/bin/bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

tmux bind P run-shell "$CURRENT_DIR/scripts/tmux-fzf-project.sh"
tmux bind S run-shell "$CURRENT_DIR/scripts/tmux-fzf-session.sh"
