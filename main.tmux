#!/usr/bin/env bash

[ -z "$DEBUG" ] || set -x

_tmux_fzf_root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/tmux_fzf_core.sh
source "$_tmux_fzf_root_dir/scripts/tmux_fzf_core.sh"

# Get user-defined key
fzf_projects_key=$(_tmux_get_option "@fzf-projects-key")
# OR use default key bind
if [ -z "$fzf_projects_key" ]; then
  fzf_projects_key="M-p"
fi

tmux bind -n "$fzf_projects_key" run-shell "$_tmux_fzf_root_dir/scripts/tmux_fzf_project.sh"

# Get user-defined key
fzf_sessions_key=$(_tmux_get_option "@fzf-sessions-key")
# OR use default key bind
if [ -z "$fzf_sessions_key" ]; then
  fzf_sessions_key="M-s"
fi

tmux bind -n "$fzf_sessions_key" run-shell "$_tmux_fzf_root_dir/scripts/tmux_fzf_session.sh"
