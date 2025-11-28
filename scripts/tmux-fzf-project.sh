#!/bin/bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/tmux-fzf-common.sh
source "$CURRENT_DIR/tmux-fzf-common.sh"

check_dependencies

# This script is adapted from ThePrimeagen's tmux-sessionizer:
# https://github.com/ThePrimeagen/tmux-sessionizer
#
# Provides functions for managing tmux sessions with fzf.

tmux_session_project() {
	local SESSION_DIR_PATH SESSION_NAME

	if [[ $# -eq 1 ]]; then
		SESSION_DIR_PATH=$1
	else
		SESSION_PROJECT_PATH=$(tmux get-option -gq "@tmux-fzf-projects-path" || echo "$HOME/Projects")
		SESSION_DIR_PATH=$(find "$SESSION_PROJECT_PATH" -mindepth 2 -maxdepth 3 -type d | fzf --tmux=100%,100% --border=none --header='  Projects')
	fi

	# Exit silently if no directory was selected.
	if [[ -z "$SESSION_DIR_PATH" ]]; then
		return 0
	fi

	SESSION_NAME=$(tmux_session_name "$SESSION_DIR_PATH")

	if ! tmux_has_session "$SESSION_NAME"; then
		tmux_new_session "$SESSION_NAME" "$SESSION_DIR_PATH"
	fi

	tmux_switch_to "$SESSION_NAME"
}

tmux_session_project "$@"
