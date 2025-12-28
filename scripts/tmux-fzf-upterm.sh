#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/core.sh
source "$CURRENT_DIR/core.sh"

# List tmux sessions with styling for fzf display.
#
# Lists all running tmux sessions with index prefixes. If gum is available,
# highlights upterm sessions in red for visual distinction.
#
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   Session names to stdout (with ANSI colors if gum is available)
# Returns:
#   0 on success
upterm_list_sessions() {
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

upterm_list_sessions "$@"
