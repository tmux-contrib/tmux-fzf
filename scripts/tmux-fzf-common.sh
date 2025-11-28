#!/bin/bash

check_dependencies() {
	if ! command -v fzf &>/dev/null; then
		tmux display-message "Error: fzf is not installed. Please install it to use this plugin."
		exit 1
	fi
}

# Switch to a given tmux session.
tmux_switch_to() {
	tmux switch-client -t "$1"
}

# Check if a tmux session exists.
tmux_has_session() {
	tmux list-sessions 2>/dev/null | grep -q "^$1:"
}

# Create a new tmux session.
tmux_new_session() {
	tmux new-session -ds "$1" -c "$2"
}

# Derive a session name from a directory path.
tmux_session_name() {
	local PROJECT WORKSPACE

	PROJECT=$(basename "$1")
	WORKSPACE=$(basename "$(dirname "$1")")

	echo "${WORKSPACE}/${PROJECT}" | tr . _
}
