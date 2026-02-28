#!/usr/bin/env bash
set -euo pipefail

[[ -z "${DEBUG:-}" ]] || set -x

_tmux_source_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

[[ -f "$_tmux_source_dir/tmux_core.sh" ]] || {
	echo "tmux-fzf: missing tmux_core.sh" >&2
	exit 1
}

# shellcheck source=tmux_core.sh
source "$_tmux_source_dir/tmux_core.sh"

# Open an existing tmux session using fzf selection
#
# Presents an fzf menu of all running sessions. Key bindings:
#   - ctrl-o: Open the session's GitHub repository in browser
#   - ctrl-x: Kill the highlighted session and reload the list
#   - space:  Jump mode for quick navigation
#   - jump:   Accept selection after jump
tmux_session_open() {
	local session_name
	local session_list="$_tmux_source_dir/tmux_fzf_cmd.sh session-list"

	local client_tty
	client_tty=$(_tmux_get_client_tty)

	# List sessions, extract their names, and use fzf to select one.
	session_name=$(
		$session_list | fzf "${_fzf_options[@]}" \
			--footer "  Sessions · $client_tty" \
			--jump-labels "123456789" \
			--bind "ctrl-o:execute-silent($_tmux_source_dir/tmux_fzf_cmd.sh github-open '{}')" \
			--bind "ctrl-x:execute(tmux kill-session -t {})+reload($session_list),space:jump,jump:accept"
	) || true

	# If a session is selected, switch to it.
	if [[ -n $session_name ]]; then
		_tmux_switch_to "$session_name"
	fi
}

tmux_session_open "$@"
