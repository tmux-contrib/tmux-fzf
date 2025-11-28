#!/bin/bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/tmux-fzf-common.sh
source "$CURRENT_DIR/tmux-fzf-common.sh"

check_dependencies

tmux_session_open() {
	local SESSION_NAME

	# List sessions, extract their names, and use fzf to select one.
	SESSION_NAME=$(tmux ls | cut -d: -f1 | fzf --tmux=100%,100% --border=none --header=' Session' --bind='ctrl-x:execute(tmux kill-session -t {})+reload(tmux ls | cut -d: -f1),space:jump,jump:accept')

	# If a session is selected, switch to it.
	if [[ -n $SESSION_NAME ]]; then
		tmux_switch_to "$SESSION_NAME"
	fi
}

tmux_session_open "$@"
