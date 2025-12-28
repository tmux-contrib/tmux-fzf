#!/usr/bin/env bash

# GitHub CLI helper script for tmux-fzf.
#
# Usage:
#   tmux-fzf-gh.sh available      - Check if gh CLI is installed (exit 0/1)
#   tmux-fzf-gh.sh open <path>    - Open repository in browser
#   tmux-fzf-gh.sh preview <path> - Get repo info for preview

set -e

gh_available() {
	command -v gh &>/dev/null
}

gh_preview() {
	local repo_path="$1"
	cd "$repo_path" && gh repo view --json 'url,description' --jq '.description // "No description", .url'
}

gh_open() {
	local repo_path="$1"
	cd "$repo_path" && gh repo view --web
}

case "${1:-}" in
available)
	gh_available
	;;
preview)
	gh_preview "$2"
	;;
open)
	gh_open "$2"
	;;
*)
	echo "Usage: tmux-gh.sh {available|open|preview} [args...]" >&2
	exit 1
	;;
esac
