#!/usr/bin/env bash

# Command helper script for tmux-fzf.
#
# Usage:
#   tmux_fzf_cmd.sh project-list              - List project directories (full paths)
#   tmux_fzf_cmd.sh project-list-depth        - Return fzf field index for --with-nth
#   tmux_fzf_cmd.sh session-list              - List sessions with styling
#   tmux_fzf_cmd.sh github-open <path|ses>    - Open repository in browser (path or session name)
#   tmux_fzf_cmd.sh upterm-open <path>        - Open project in upterm

_fzf_cmd_source_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tmux_fzf_core.sh
source "$_fzf_cmd_source_dir/tmux_fzf_core.sh"

# List project directories using fd (full paths).
project_list() {
	local dir_path
	dir_path="$(tmux_get_option "@fzf-projects-path" "$HOME/Projects")"
	fd -t d --max-depth 3 --min-depth 3 . "$dir_path" | sed 's|/$||'
}

# Return fzf field index to start display from (for --with-nth).
project_list_depth() {
	local dir_path
	dir_path="$(tmux_get_option "@fzf-projects-path" "$HOME/Projects")"
	echo $(($(echo "$dir_path" | tr -cd '/' | wc -c) + 2))
}

# List tmux sessions with styling for fzf display.
#
# Lists all running tmux sessions. If gum is available,
# highlights upterm sessions in red for visual distinction.
#
# Outputs:
#   Session names to stdout (with ANSI colors if gum is available)
session_list() {
	if command -v gum >/dev/null 2>&1; then
		while read -r name flag; do
			if [ "$flag" = "1" ] || [ "$flag" = "true" ]; then
				CLICOLOR_FORCE=1 gum style --foreground 9 "$name"
			else
				echo "$name"
			fi
		done < <(tmux list-sessions -F '#{session_name} #{@is_upterm_session}')
	else
		tmux_list_sessions
	fi
}

# Open GitHub repository in browser, or Finder if not a git repo.
#
# Arguments:
#   $1 - Full path to project directory, OR session name
#
# If $1 is a directory, opens it directly.
# If $1 is not a directory, treats it as a session name and looks up @fzf-session-cwd.
github_open() {
	local target="$1"
	local dir

	if [[ -d "$target" ]]; then
		dir="$target"
	else
		# Treat as session name, look up stored working directory
		dir="$(tmux_get_option_for_session "$target" "@fzf-session-cwd")"
		if [[ -z "$dir" ]]; then
			tmux display-message "No project path stored for session: $target"
			return 1
		fi
	fi

	cd "$dir" || return 1
	if git rev-parse --git-dir >/dev/null 2>&1; then
		gh repo view --web 2>/dev/null || open .
	else
		open .
	fi
}

# Open project in upterm (if available).
#
# Arguments:
#   $1 - Full path to the project
upterm_open() {
	local upterm="$TMUX_PLUGIN_MANAGER_PATH/tmux-upterm/scripts/tmux-upterm.sh"
	[[ -f "$upterm" ]] && "$upterm" "$1"
}

case "${1:-}" in
project-list)
	project_list
	;;
project-list-depth)
	project_list_depth
	;;
session-list)
	session_list
	;;
github-open)
	github_open "$2"
	;;
upterm-open)
	upterm_open "$2"
	;;
*)
	echo "Usage: tmux_fzf_cmd.sh {project-list|session-list|github-open|upterm-open} [args...]" >&2
	exit 1
	;;
esac
