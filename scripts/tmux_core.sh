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
#   $@ - (optional) command and arguments to run instead of the default shell
# Side effects:
#   Stores the working directory as @fzf-session-cwd session option.
_tmux_new_session() {
	tmux new-session -ds "$1" -c "$2" "${@:3}"
	_tmux_set_session_option "$1" "@fzf-session-cwd" "$2"
}

# Create a new window in the current session and switch to it
#
# Arguments:
#   $1 - window name
#   $2 - working directory path
#   $@ - (optional) command and arguments to run instead of the default shell
_tmux_new_window() {
	tmux new-window -n "$1" -c "$2" "${@:3}"
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

# Derive a vagrant box label from its directory and machine name
#
# Combines the Vagrantfile directory basename and the machine name, since the
# machine name alone is usually "default". Dots and colons are replaced with
# underscores because tmux does not allow them in session names.
#
# Arguments:
#   $1 - Vagrantfile directory path
#   $2 - machine name
# Outputs:
#   Label in "directory/machine" format
_tmux_vagrant_name() {
	echo "$(basename "$1")/$2" | tr '.:' '__'
}

# Format "vagrant global-status" output for fzf display
#
# Reads the human-readable table on stdin and emits one aligned line per box:
# "id name state provider directory". The directory is the remainder of the
# line, so paths containing spaces are preserved. Prose after the table is
# ignored, and no output is produced when there are no boxes.
#
# Outputs:
#   One line per vagrant box to stdout
_vagrant_parse_status() {
	awk '
		function pad(s, w) {
			while (length(s) < w) s = s " "
			return s
		}
		/^-+[ \t]*$/ { body = 1; next }
		!body { next }
		NF == 0 { exit }
		{
			dir = $0
			for (i = 0; i < 4; i++) sub(/^[ \t]*[^ \t]+/, "", dir)
			sub(/^[ \t]+/, "", dir)
			sub(/[ \t]+$/, "", dir)
			n++
			id[n] = $1; name[n] = $2; prov[n] = $3; state[n] = $4; path[n] = dir
			if (length($1) > wi) wi = length($1)
			if (length($2) > wn) wn = length($2)
			if (length($4) > ws) ws = length($4)
			if (length($3) > wp) wp = length($3)
		}
		END {
			for (i = 1; i <= n; i++)
				print pad(id[i], wi) "  " pad(name[i], wn) "  " pad(state[i], ws) "  " pad(prov[i], wp) "  " path[i]
		}
	'
}

# Build the shell command that opens a vagrant box over ssh
#
# Boxes that are not running are started first. If "vagrant up" fails, the
# error is kept on screen until a key is pressed so it is not lost when the
# tmux session or window closes.
#
# Arguments:
#   $1 - vagrant machine id
#   $2 - machine state (e.g. running, poweroff)
# Outputs:
#   POSIX shell command string
_vagrant_ssh_command() {
	local id="$1"
	local state="$2"

	if [[ "$state" = "running" ]]; then
		echo "vagrant ssh $id"
	else
		printf '%s\n' "vagrant up $id || { printf '\\nvagrant up failed. Press enter to close. '; read -r _; exit 1; }; vagrant ssh $id"
	fi
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

	value="$(tmux show-option -t "$session" -qv "$option" 2>/dev/null)"
	echo "${value:-$default}"
}

# Get the TTY of the current tmux client
#
# Outputs:
#   Client TTY path (e.g., /dev/ttys001)
_tmux_get_client_tty() {
	tmux display-message -p '#{client_tty}'
}
