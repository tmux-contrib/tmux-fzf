#!/usr/bin/env bash

[ -z "$DEBUG" ] || set -x

_tmux_root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/tmux_core.sh
source "$_tmux_root_dir/scripts/tmux_core.sh"

_check_dependencies

# Get user-defined prefix key (default: f)
fzf_prefix_key=$(_tmux_get_option "@fzf-prefix-key")
if [ -z "$fzf_prefix_key" ]; then
	fzf_prefix_key="f"
fi

# Bind the prefix key to enter the fzf menu
tmux bind "$fzf_prefix_key" switch-client -T fzf-menu

# Get user-defined keys for projects and sessions
fzf_projects_key=$(_tmux_get_option "@fzf-projects-key")
if [ -z "$fzf_projects_key" ]; then
	fzf_projects_key="p"
fi

fzf_sessions_key=$(_tmux_get_option "@fzf-sessions-key")
if [ -z "$fzf_sessions_key" ]; then
	fzf_sessions_key="s"
fi

# Bind keys within the fzf-menu table
tmux bind -T fzf-menu "$fzf_projects_key" run-shell "$_tmux_root_dir/scripts/tmux_fzf_project.sh"
tmux bind -T fzf-menu "$fzf_sessions_key" run-shell "$_tmux_root_dir/scripts/tmux_fzf_session.sh"
