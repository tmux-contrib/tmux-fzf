#!/usr/bin/env bash
# tmux_core.sh — shared library; meant to be sourced, not executed directly.

_fzf_options=(
	--ansi
	--tmux
	--border='sharp'
	--delimiter='/'
	--color='footer:red'
	--footer-border='sharp'
	--input-border='sharp'
	--layout='reverse-list'
)

# Check if required dependencies (fzf, fd) are installed
#
# Displays an error via tmux and exits if any dependency is missing.
_check_dependencies() {
	if ! command -v fzf &>/dev/null; then
		tmux display-message "Error: fzf is not installed. Please install it to use this plugin."
		exit 1
	fi
	if ! command -v fd &>/dev/null; then
		tmux display-message "Error: fd is not installed. Please install it to use this plugin."
		exit 1
	fi
}

# Switch to a given tmux session
#
# Arguments:
#   $1 - session name
_tmux_switch_to() {
	tmux switch-client -t "$1"
}

# Check if a tmux session exists
#
# Arguments:
#   $1 - session name
_tmux_has_session() {
	tmux has-session -t "$1" 2>/dev/null
}

# List all tmux sessions
#
# Outputs:
#   Session names to stdout, one per line
_tmux_list_sessions() {
	tmux list-sessions -F '#{session_name}'
}

# Create a new detached tmux session
#
# Arguments:
#   $1 - session name
#   $2 - working directory path
# Side effects:
#   Stores the working directory as @fzf-session-cwd session option.
_tmux_new_session() {
	tmux new-session -ds "$1" -c "$2"
	_tmux_set_session_option "$1" "@fzf-session-cwd" "$2"
}

# Derive a session name from a directory path
#
# Combines the parent directory (workspace) and basename (project) with a
# forward slash, replacing dots with underscores for tmux compatibility.
#
# Arguments:
#   $1 - directory path
# Outputs:
#   Session name in "workspace/project" format
_tmux_session_name() {
	local project workspace

	project=$(basename "$1")
	workspace=$(basename "$(dirname "$1")")

	echo "$workspace/$project" | tr . _
}

# Get a tmux option with default fallback
#
# Arguments:
#   $1 - option name
#   $2 - (optional) default value
# Outputs:
#   Option value or default
_tmux_get_option() {
	local option="$1"
	local default="${2:-}"
	local value

	value="$(tmux show-option -gqv "$option" 2>/dev/null)"
	echo "${value:-$default}"
}

# Set a tmux session option
#
# Arguments:
#   $1 - session name
#   $2 - option name
#   $3 - value
_tmux_set_session_option() {
	local session="$1"
	local option="$2"
	local value="$3"
	tmux set-option -t "$session" "$option" "$value"
}

# Get a tmux session option with default fallback
#
# Arguments:
#   $1 - session name
#   $2 - option name
#   $3 - (optional) default value
# Outputs:
#   Option value or default
_tmux_get_session_option() {
	local session="$1"
	local option="$2"
	local default="${3:-}"
	local value

	value="$(tmux show-options -t "$session" -qv "$option" 2>/dev/null)"
	echo "${value:-$default}"
}

# Get the TTY of the current tmux client
#
# Outputs:
#   Client TTY path (e.g., /dev/ttys001)
_tmux_get_client_tty() {
	tmux display-message -p '#{client_tty}'
}
