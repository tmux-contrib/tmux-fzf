#!/usr/bin/env bash
set -euo pipefail

[[ -z "${DEBUG:-}" ]] || set -x

_tmux_fzf_source_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

[[ -f "$_tmux_fzf_source_dir/tmux_core.sh" ]] || {
	echo "tmux-fzf: missing tmux_core.sh" >&2
	exit 1
}

# shellcheck source=tmux_core.sh
source "$_tmux_fzf_source_dir/tmux_core.sh"

# This script is adapted from ThePrimeagen's tmux-sessionizer:
# https://github.com/ThePrimeagen/tmux-sessionizer

# Create or switch to a tmux session for a project directory
#
# Presents an fzf menu to select a project directory. Key bindings:
#   - ctrl-o: Open GitHub repository in browser
#   - ctrl-t: Open project in upterm (if available)
tmux_project_open() {
	local project_name
	local project_path

	local project_dir
	project_dir="$("$_tmux_fzf_source_dir/tmux_fzf.sh" project-dir)"
	# Let's make the project path display cleaner by using ~ for home directory.
	if [[ $project_dir == $HOME/* ]]; then
		# shellcheck disable=SC2088 disable=SC2295
		project_dir="~/${project_dir#$HOME/}"
	fi

	local project_list
	project_list="$_tmux_fzf_source_dir/tmux_fzf.sh project-list"

	local project_list_depth
	project_list_depth=$("$_tmux_fzf_source_dir/tmux_fzf.sh" project-list-depth)
	# List project directories and use fzf to select one.
	project_path=$(
		$project_list | fzf "${_fzf_options[@]}" \
			--footer "  $project_dir" \
			--with-nth="$project_list_depth.." \
			--bind "ctrl-o:execute-silent($_tmux_fzf_source_dir/tmux_fzf.sh github-open '{}')" \
			--bind "ctrl-t:execute($_tmux_fzf_source_dir/tmux_fzf.sh upterm-open '{}')+abort"
	) || true

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
