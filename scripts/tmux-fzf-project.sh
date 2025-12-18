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
# Arguments:
#   $1 - (Optional) The directory path to create/switch to a session for
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

	if [[ $# -eq 1 ]]; then
		session_dir_path=$1
	else
		local session_project_path git_only fzf_header
		session_project_path=$(tmux get-option -gq "@tmux-fzf-projects-path" || echo "$HOME/Projects")
		git_only=$(tmux get-option -gq "@tmux-fzf-projects-git-only" || echo "true")

		if [[ "$git_only" == "true" ]]; then
			fzf_header='  Projects'
			session_dir_path=$(cd "$session_project_path" && fd -H -t d '^\.git$' --max-depth 4 --min-depth 3 . --exec dirname | sed 's|^\./||' | fzf --tmux=100%,100% --border=none --header="$fzf_header" --bind="ctrl-o:execute(cd '$session_project_path/{}' && gh repo view --web)+abort")
		else
			fzf_header='  Projects'
			session_dir_path=$(cd "$session_project_path" && fd -t d --max-depth 3 --min-depth 2 . | sed 's|^\./||' | fzf --tmux=100%,100% --border=none --header="$fzf_header")
		fi

		# Convert relative path back to absolute
		if [[ -n "$session_dir_path" && "$session_dir_path" != /* ]]; then
			session_dir_path="$session_project_path/$session_dir_path"
		fi
	fi

	# Exit silently if no directory was selected.
	if [[ -z "$session_dir_path" ]]; then
		return 0
	fi

	session_name=$(tmux_session_name "$session_dir_path")

	if ! tmux_has_session "$session_name"; then
		tmux_new_session "$session_name" "$session_dir_path"
	fi

	tmux_switch_to "$session_name"
}

tmux_session_project "$@"
