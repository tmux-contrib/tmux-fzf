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

# Open a vagrant box over ssh using fzf selection
#
# Presents an fzf menu of the boxes known to "vagrant global-status". Boxes
# that are not running are started first. Key bindings:
#   - enter:  Open the box in its own "vagrant/<directory>/<name>" session
#   - ctrl-w: Open the box in a new window of the current session
#   - ctrl-x: Halt the highlighted box and reload the list
#   - ctrl-p: Prune stale entries from vagrant's index and reload the list
#
# vagrant is an optional dependency: a message is shown if it is missing.
tmux_vagrant_open() {
	if ! command -v vagrant >/dev/null 2>&1; then
		tmux display-message "tmux-fzf: vagrant is not installed"
		return 0
	fi

	local tmux_fzf="$_tmux_fzf_source_dir/tmux_fzf.sh"
	local vagrant_list="$tmux_fzf vagrant-list"

	local boxes
	boxes=$($vagrant_list) || true
	if [[ -z "$boxes" ]]; then
		tmux display-message "tmux-fzf: no vagrant boxes found"
		return 0
	fi

	# User options (@fzf-vagrant-fzf-options) are appended last so they can
	# override the defaults.
	_fzf_load_user_options vagrant

	# With --expect, fzf prints the pressed key (empty for enter) on the first
	# line and the selected entry on the second.
	local output
	output=$(
		fzf "${_fzf_options[@]}" \
			--expect "ctrl-w" \
			--header-lines=1 \
			--footer " Vagrant Boxes" \
			--bind "ctrl-x:execute($tmux_fzf vagrant-halt {})+reload($vagrant_list)" \
			--bind "ctrl-p:execute-silent($tmux_fzf vagrant-prune)+reload($vagrant_list)" \
			${_fzf_user_options[@]+"${_fzf_user_options[@]}"} \
			<<<"$boxes"
	) || true

	local key="" selection=""
	{
		IFS= read -r key
		IFS= read -r selection
	} <<<"$output" || true

	if [[ -z "$selection" ]]; then
		return 0
	fi

	# Fields: id name state provider directory (the provider is not needed).
	local id name state dir
	read -r id name state _ dir <<<"$selection"

	local label command
	label=$(_tmux_vagrant_name "$dir" "$name")
	command=$(_vagrant_ssh_command "$id" "$state")

	if [[ "$key" = "ctrl-w" ]]; then
		_tmux_new_window "$label" "$dir" sh -c "$command"
		return 0
	fi

	# Machine names are usually "default", so two boxes can map to the same
	# session name. Keep them apart by suffixing the machine id on a clash.
	local session="vagrant/$label"
	if _tmux_has_session "$session" &&
		[[ "$(_tmux_get_session_option "$session" "@fzf-vagrant-id")" != "$id" ]]; then
		session="$session-$id"
	fi

	if ! _tmux_has_session "$session"; then
		_tmux_new_session "$session" "$dir" sh -c "$command"
		_tmux_set_session_option "$session" "@fzf-vagrant-id" "$id" || true
	fi
	_tmux_switch_to "$session"
}

tmux_vagrant_open "$@"
