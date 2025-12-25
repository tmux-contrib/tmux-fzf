#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/core.sh
source "$CURRENT_DIR/core.sh"

check_dependencies

# This script is adapted from ThePrimeagen's tmux-sessionizer:
# https://github.com/ThePrimeagen/tmux-sessionizer
#
# Provides functions for managing tmux sessions with fzf.

# Create or switch to a tmux session for a project directory.
#
# If a directory path is provided as an argument, creates or switches to a session
# for that directory. Otherwise, presents an fzf menu to select a project directory
# from the configured projects path. The fzf menu includes a ctrl-o binding to open
# the selected project's GitHub repository in the browser using the gh CLI.
#
# By default, only directories containing a .git subdirectory are shown. This can
# be disabled by setting @tmux-fzf-projects-git-only to "false".
#
# Globals:
#   None
# Returns:
#   0 on success or if no directory was selected
# Dependencies:
#   - fzf: for interactive directory selection
#   - fd: for fast directory traversal (replaces find)
#   - gh: (optional) for opening GitHub repositories with ctrl-o
#   - tmux get-option: to read @tmux-fzf-projects-path and @tmux-fzf-projects-git-only configuration
tmux_session_project() {
	local session_name
	local session_dir_path
	local session_params=()
	local projects_git_only
	local projects_dir_path

	projects_git_only="$(tmux_get_option "@fzf-projects-git-only" "true")"
	projects_dir_path="$(tmux_get_option "@fzf-projects-path" "$HOME/Projects")"
	# list the available directories
	projects_dir_list=$(fd_list "$projects_dir_path" "$projects_git_only")

	if [[ "$projects_git_only" == "true" ]]; then
		session_params+=(--header "  Projects")

		if command -v gh &>/dev/null; then
			# Add ctrl-o binding to open GitHub repo in browser if gh CLI is available.
			session_params+=(--bind "ctrl-o:execute(cd '$projects_dir_path/{}' && gh repo view --web)+abort")
		fi
	else
		session_params+=(--header "  Projects")
	fi

	upterm="$TMUX_PLUGIN_MANAGER_PATH/tmux-upterm/scripts/tmux-upterm.sh"
	# Add ctrl-u binding to open selected project in upterm if available.
	if [[ -f "$upterm" ]]; then
		session_params+=(--bind "ctrl-t:execute($upterm '$projects_dir_path/{}')+abort")
	fi

	session_dir_path=$(
		echo "$projects_dir_list" | fzf --ansi \
			--border none \
			--tmux 100%,100% \
			"${session_params[@]}"
	)

	# Exit silently if no directory was selected.
	if [[ -z "$session_dir_path" ]]; then
		return 0
	fi

	session_dir_path="$projects_dir_path/$session_dir_path"
	session_name=$(tmux_session_name "$session_dir_path")

	if ! tmux_has_session "$session_name"; then
		tmux_new_session "$session_name" "$session_dir_path"
	fi

	tmux_switch_to "$session_name"
}

tmux_session_project "$@"
