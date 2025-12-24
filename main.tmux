#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/core.sh
source "$CURRENT_DIR/core.sh"

# Get user-defined key
fzf_projects_key=$(tmux_get_option "@fzf-projects-key")
# OR use default key bind
if [ -z "$fzf_projects_key" ]; then
  fzf_projects_key="P"
fi

tmux bind "$fzf_projects_key" run-shell "$CURRENT_DIR/scripts/tmux-fzf-project.sh"

# Get user-defined key
fzf_sessions_key=$(tmux_get_option "@fzf-sessions-key")
# OR use default key bind
if [ -z "$fzf_sessions_key" ]; then
  fzf_sessions_key="S"
fi

tmux bind "$fzf_sessions_key" run-shell "$CURRENT_DIR/scripts/tmux-fzf-session.sh"
