#!/usr/bin/env bash

# GitHub CLI helper script for tmux-fzf.
#
# Usage:
#   tmux-gh.sh available          - Check if gh CLI is installed (exit 0/1)
#   tmux-gh.sh open <path>        - Open repository in browser
#   tmux-gh.sh preview <path> [fields] [filter] - Get repo info for preview

set -e

gh_available() {
	command -v gh &>/dev/null
}

gh_open() {
	local repo_path="$1"
	cd "$repo_path" && gh repo view --web
}

gh_preview() {
	local repo_path="$1"
	local fields="${2:-url,description}"
	local filter="${3:-.description // \"No description\", .url}"
	cd "$repo_path" && gh repo view --json "$fields" --jq "$filter"
}

case "${1:-}" in
available)
	gh_available
	;;
preview)
	gh_preview "$2" "$3" "$4"
	;;
open)
	gh_open "$2"
	;;
*)
	echo "Usage: tmux-gh.sh {available|open|preview} [args...]" >&2
	exit 1
	;;
esac
