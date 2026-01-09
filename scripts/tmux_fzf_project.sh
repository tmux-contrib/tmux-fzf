#!/usr/bin/env bash

_tmux_source_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tmux_core.sh
source "$_tmux_source_dir/tmux_core.sh"

# This script is adapted from ThePrimeagen's tmux-sessionizer:
# https://github.com/ThePrimeagen/tmux-sessionizer
#
# Provides functions for managing tmux sessions with fzf.

# Create or switch to a tmux session for a project directory.
#
# Presents an fzf menu to select a project directory from the configured projects
# path. The fzf menu includes key bindings:
#   - ctrl-o: Open GitHub repository in browser (falls back to Finder if not a repo)
#   - ctrl-t: Open project in upterm (if available)
#
# Globals:
#   None
# Returns:
#   0 on success or if no directory was selected
# Dependencies:
#   - fzf: for interactive directory selection
#   - fd: for fast directory traversal
#   - gh: (optional) for opening GitHub repositories with ctrl-o
#   - tmux get-option: to read @fzf-projects-path configuration
tmux_project_open() {
	local project_name
	local project_path

	local project_dir
	project_dir="$("$_tmux_source_dir/tmux_fzf_cmd.sh" project-dir)"
	# Let's make the project path display cleaner by using ~ for home directory.
	if [[ $project_dir == $HOME/* ]]; then
		# shellcheck disable=SC2088 disable=SC2295
		project_dir="~/${project_dir#$HOME/}"
	fi

	local project_list
	project_list="$_tmux_source_dir/tmux_fzf_cmd.sh project-list"

	local project_list_depth
	project_list_depth=$("$_tmux_source_dir/tmux_fzf_cmd.sh" project-list-depth)
	# List project directories and use fzf to select one.
	project_path=$(
		$project_list | fzf "${_fzf_options[@]}" \
			--footer "  $project_dir" \
			--with-nth="$project_list_depth.." \
			--bind "ctrl-o:execute-silent($_tmux_source_dir/tmux_fzf_cmd.sh github-open '{}')" \
			--bind "ctrl-t:execute($_tmux_source_dir/tmux_fzf_cmd.sh upterm-open '{}')+abort"
	)

	# Exit silently if no directory was selected.
	if [[ -z "$project_path" ]]; then
		return 0
	fi

	project_name=$(_tmux_session_name "$project_path")
	# Create a new tmux session for the project if it doesn't exist.
	if ! _tmux_has_session "$project_name"; then
		_tmux_new_session "$project_name" "$project_path"
	fi

	_tmux_switch_to "$project_name"
}

tmux_project_open "$@"
