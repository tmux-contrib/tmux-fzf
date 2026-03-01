#!/usr/bin/env bash
set -euo pipefail

[[ -z "${DEBUG:-}" ]] || set -x

_tmux_fzf_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

[[ -f "$_tmux_fzf_root/scripts/tmux_core.sh" ]] || {
	echo "tmux-fzf: missing tmux_core.sh" >&2
	exit 1
}

# shellcheck source=scripts/tmux_core.sh
source "$_tmux_fzf_root/scripts/tmux_core.sh"

main() {
	_check_dependencies

	# Get user-defined prefix key (default: f)
	local fzf_prefix_key
	fzf_prefix_key=$(_tmux_get_option "@fzf-prefix-key")
	fzf_prefix_key=${fzf_prefix_key:-'f'}

	# Bind the prefix key to enter the fzf menu
	tmux bind "$fzf_prefix_key" switch-client -T fzf-menu

	# Get user-defined keys for projects and sessions
	local fzf_projects_key
	fzf_projects_key=$(_tmux_get_option "@fzf-projects-key")
	fzf_projects_key=${fzf_projects_key:-'p'}

	local fzf_sessions_key
	fzf_sessions_key=$(_tmux_get_option "@fzf-sessions-key")
	fzf_sessions_key=${fzf_sessions_key:-'s'}

	# Bind keys within the fzf-menu table
	tmux bind -T fzf-menu "$fzf_projects_key" run-shell "$_tmux_fzf_root/scripts/tmux_fzf_project.sh"
	tmux bind -T fzf-menu "$fzf_sessions_key" run-shell "$_tmux_fzf_root/scripts/tmux_fzf_session.sh"
}

main
