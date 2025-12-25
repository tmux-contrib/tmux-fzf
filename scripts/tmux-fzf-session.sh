#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/core.sh
source "$CURRENT_DIR/core.sh"

# List tmux sessions with styling for fzf display.
#
# Lists all running tmux sessions. If gum is available, highlights
# upterm sessions in red for visual distinction.
#
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   Session names to stdout (with ANSI colors if gum is available)
# Returns:
#   0 on success
tmux_list_sessions_styled() {
	if command -v gum >/dev/null 2>&1; then
		tmux list-sessions -F '#{session_name} #{@is_upterm_session}' |
			while read -r name flag; do
				if [ "$flag" = "1" ] || [ "$flag" = "true" ]; then
					CLICOLOR_FORCE=1 gum style --foreground 9 "$name"
				else
					echo "$name"
				fi
			done
	else
		tmux_list_sessions
	fi
}

# Handle --list flag for fzf reload
if [[ "$1" == "--list" ]]; then
	tmux_list_sessions_styled
	exit 0
fi

check_dependencies

# Open an existing tmux session using fzf selection.
#
# Presents an fzf menu of all running tmux sessions and switches to the selected one.
# The fzf menu includes interactive key bindings:
#   - ctrl-x: Kill the highlighted session and reload the list
#   - space: Jump mode for quick navigation
#   - jump: Accept selection after jump
#
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   0 on success or if no session was selected
# Dependencies:
#   - fzf: for interactive session selection
#   - tmux ls: to list available sessions
tmux_session_open() {
	local session_name

	# List sessions, extract their names, and use fzf to select one.
	session_name=$(
		tmux_list_sessions_styled | fzf --ansi \
			--border none \
			--tmux 100%,100% \
			--header " Session" \
			--bind "ctrl-x:execute(tmux kill-session -t {})+reload($CURRENT_DIR/tmux-fzf-session.sh --list),space:jump,jump:accept"
	)

	# If a session is selected, switch to it.
	if [[ -n $session_name ]]; then
		tmux_switch_to "$session_name"
	fi
}

tmux_session_open "$@"
