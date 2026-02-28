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

# Check if required dependencies are installed.
#
# Verifies that fzf and fd are installed and available in the system PATH.
# If any dependency is not found, displays an error message and exits with status 1.
#
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   0 if all dependencies are installed
#   1 if any dependency is missing
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

# Switch to a given tmux session.
#
# Switches the current tmux client to the specified session.
#
# Globals:
#   None
# Arguments:
#   $1 - The name of the tmux session to switch to
# Returns:
#   0 on success, non-zero on failure
_tmux_switch_to() {
	tmux switch-client -t "$1"
}

# Check if a tmux session exists.
#
# Determines whether a tmux session with the given name is currently running.
#
# Globals:
#   None
# Arguments:
#   $1 - The name of the tmux session to check
# Returns:
#   0 if the session exists
#   1 if the session does not exist
_tmux_has_session() {
	tmux has-session -t "$1" 2>/dev/null
}

# List all tmux sessions.
#
# Lists all running tmux sessions by name.
#
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   Session names to stdout, one per line
# Returns:
#   0 on success
_tmux_list_sessions() {
	tmux list-sessions -F '#{session_name}'
}

# Create a new tmux session.
#
# Creates a new detached tmux session with the specified name and working directory.
# Also stores the working directory as a session option for later retrieval.
#
# Globals:
#   None
# Arguments:
#   $1 - The name for the new tmux session
#   $2 - The working directory path for the session
# Returns:
#   0 on success, non-zero on failure
_tmux_new_session() {
	tmux new-session -ds "$1" -c "$2"
	_tmux_set_session_option "$1" "@fzf-session-cwd" "$2"
}

# Derive a session name from a directory path.
#
# Generates a tmux session name by combining the workspace (parent directory)
# and project (directory name) with a forward slash, and replacing dots with
# underscores to ensure tmux compatibility.
#
# Globals:
#   None
# Arguments:
#   $1 - The directory path to derive the session name from
# Returns:
#   0 on success
# Outputs:
#   The generated session name in the format "workspace/project"
_tmux_session_name() {
	local project workspace

	project=$(basename "$1")
	workspace=$(basename "$(dirname "$1")")

	echo "$workspace/$project" | tr . _
}

# Get a tmux option value.
#
# Retrieves the value of a global tmux option. If the option is not set,
# returns the provided default value.
#
# Globals:
#   None
# Arguments:
#   $1 - The name of the tmux option to retrieve
#   $2 - (optional) The default value to return if the option is not set
# Outputs:
#   The option value or default value to stdout
# Returns:
#   0 on success
_tmux_get_option() {
	local option="$1"
	local default="${2:-}"
	local value

	value="$(tmux show-option -gqv "$option" 2>/dev/null)"
	echo "${value:-$default}"
}

# Set a tmux session option.
#
# Sets the value of an option for a specific tmux session.
#
# Globals:
#   None
# Arguments:
#   $1 - The name of the tmux session
#   $2 - The name of the option to set
#   $3 - The value to set
# Returns:
#   0 on success, non-zero on failure
_tmux_set_session_option() {
	local session="$1"
	local option="$2"
	local value="$3"
	tmux set-option -t "$session" "$option" "$value"
}

# Get a tmux session option value.
#
# Retrieves the value of an option for a specific tmux session.
#
# Globals:
#   None
# Arguments:
#   $1 - The name of the tmux session
#   $2 - The name of the option to retrieve
#   $3 - (optional) The default value to return if the option is not set
# Outputs:
#   The option value or default value to stdout
# Returns:
#   0 on success
_tmux_get_session_option() {
	local session="$1"
	local option="$2"
	local default="${3:-}"
	local value

	value="$(tmux show-options -t "$session" -qv "$option" 2>/dev/null)"
	echo "${value:-$default}"
}

# Get the TTY of the current tmux client.
#
# Retrieves the terminal device path for the active tmux client.
#
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   The client TTY path to stdout (e.g., /dev/ttys001)
# Returns:
#   0 on success
_tmux_get_client_tty() {
	tmux display-message -p '#{client_tty}'
}
