#!/usr/bin/env bash

_tmux_fzf_session_source_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tmux_fzf_core.sh
source "$_tmux_fzf_session_source_dir/tmux_fzf_core.sh"

check_dependencies

# Open an existing tmux session using fzf selection.
#
# Presents an fzf menu of all running tmux sessions and switches to the selected one.
# The fzf menu includes interactive key bindings:
#   - ctrl-o: Open the session's GitHub repository in browser
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
	local session_list="$_tmux_fzf_session_source_dir/tmux_fzf_cmd.sh session-list"

	# List sessions, extract their names, and use fzf to select one.
	session_name=$(
		$session_list | fzf "${_fzf_options[@]}" \
			--footer " Session" \
			--jump-labels "123456789" \
			--bind "ctrl-o:execute-silent($_tmux_fzf_session_source_dir/tmux_fzf_cmd.sh github-open '{}')" \
			--bind "ctrl-x:execute(tmux kill-session -t {})+reload($session_list),space:jump,jump:accept"
	)

	# If a session is selected, switch to it.
	if [[ -n $session_name ]]; then
		tmux_switch_to "$session_name"
	fi
}

tmux_session_open "$@"
