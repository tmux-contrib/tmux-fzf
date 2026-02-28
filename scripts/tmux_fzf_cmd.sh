#!/usr/bin/env bash
set -euo pipefail

[[ -z "${DEBUG:-}" ]] || set -x

# Command helper script for tmux-fzf.

_tmux_source_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

[[ -f "$_tmux_source_dir/tmux_core.sh" ]] || {
	echo "tmux-fzf: missing tmux_core.sh" >&2
	exit 1
}

# shellcheck source=tmux_core.sh
source "$_tmux_source_dir/tmux_core.sh"

# Return the configured projects directory
#
# Outputs:
#   Projects directory path (default: ~/Projects)
_project_dir() {
	_tmux_get_option "@fzf-projects-path" "$HOME/Projects"
}

# List project directories using fd (full paths)
#
# Searches 3 levels deep under the projects directory (host/workspace/project).
#
# Outputs:
#   Full directory paths to stdout, one per line
_project_list() {
	local dir_path
	dir_path="$(_project_dir)"
	fd -t d --max-depth 3 --min-depth 3 . "$dir_path" | sed 's|/$||'
}

# Return fzf field index to start display from (for --with-nth)
#
# Calculates the slash-delimited field offset so fzf displays only
# the host/workspace/project portion of each path.
#
# Outputs:
#   Numeric field index
_project_list_depth() {
	local dir_path
	dir_path="$(_project_dir)"
	echo $(($(echo "$dir_path" | tr -cd '/' | wc -c) + 2))
}

# List tmux sessions with styling for fzf display
#
# If gum is available, highlights upterm sessions in red.
#
# Outputs:
#   Session names to stdout (with ANSI colors if gum is available)
_session_list() {
	if command -v gum >/dev/null 2>&1; then
		while read -r name flag; do
			if [[ "$flag" = "1" ]] || [[ "$flag" = "true" ]]; then
				CLICOLOR_FORCE=1 gum style --foreground 9 "$name"
			else
				echo "$name"
			fi
		done < <(tmux list-sessions -F '#{session_name} #{@is_upterm_session}')
	else
		_tmux_list_sessions
	fi
}

# Open GitHub repository in browser, or Finder if not a git repo
#
# If $1 is a directory, opens it directly.
# If $1 is not a directory, treats it as a session name and looks up @fzf-session-cwd.
#
# Arguments:
#   $1 - full path to project directory, OR session name
_github_open() {
	local target="$1"
	local dir

	if [[ -d "$target" ]]; then
		dir="$target"
	else
		# Treat as session name, look up stored working directory
		dir="$(_tmux_get_session_option "$target" "@fzf-session-cwd")"
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

# Open project in upterm (if available)
#
# Arguments:
#   $1 - full path to the project
_upterm_open() {
	local upterm="$TMUX_PLUGIN_MANAGER_PATH/tmux-upterm/scripts/tmux_upterm.sh"
	if [[ -f "$upterm" ]]; then
		"$upterm" "$1"
	fi
}

# Main command router
#
# Arguments:
#   $1 - command name
#   $@ - command-specific arguments
# Commands:
#   --version          - Print plugin version
#   project-dir        - Return configured projects directory
#   project-list       - List project directories (full paths)
#   project-list-depth - Return fzf field index for --with-nth
#   session-list       - List sessions with styling
#   github-open        - Open repository in browser (path or session name)
#   upterm-open        - Open project in upterm
main() {
	local command="${1:-}"
	shift || true

	case "$command" in
	--version)
		cat "$_tmux_source_dir/../version.txt"
		;;
	project-dir)
		_project_dir
		;;
	project-list)
		_project_list
		;;
	project-list-depth)
		_project_list_depth
		;;
	session-list)
		_session_list
		;;
	github-open)
		_github_open "$1"
		;;
	upterm-open)
		_upterm_open "$1"
		;;
	*)
		echo "Usage: tmux_fzf_cmd.sh {--version|project-dir|project-list|project-list-depth|session-list|github-open|upterm-open} [args...]" >&2
		exit 1
		;;
	esac
}

main "$@"
