#!/usr/bin/env bash

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
check_dependencies() {
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
tmux_switch_to() {
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
tmux_has_session() {
	tmux list-sessions 2>/dev/null | grep -q "^$1:"
}

# Create a new tmux session.
#
# Creates a new detached tmux session with the specified name and working directory.
#
# Globals:
#   None
# Arguments:
#   $1 - The name for the new tmux session
#   $2 - The working directory path for the session
# Returns:
#   0 on success, non-zero on failure
tmux_new_session() {
	tmux new-session -ds "$1" -c "$2"
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
tmux_session_name() {
	local PROJECT WORKSPACE

	PROJECT=$(basename "$1")
	WORKSPACE=$(basename "$(dirname "$1")")

	echo "${WORKSPACE}/${PROJECT}" | tr . _
}

fd_list() {
	local dir_path="$1"
	local git_only="$2"

	if [[ "$git_only" == "true" ]]; then
		(cd "$dir_path" && fd -H -t d '^\.git$' --max-depth 4 --min-depth 3 . --exec dirname | sed 's|^\./||')
	else
		(cd "$dir_path" && fd -t d --max-depth 3 --min-depth 2 . | sed 's|^\./||')
	fi
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
#   $2 - The default value to return if the option is not set
# Outputs:
#   The option value or default value to stdout
# Returns:
#   0 on success
tmux_get_option() {
	local option="$1"
	local default_value="$2"
	local option_value

	option_value="$(tmux show-option -gqv "$option")"
	[[ -n "$option_value" ]] && echo "$option_value" || echo "$default_value"
}
