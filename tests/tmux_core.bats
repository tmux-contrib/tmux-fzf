#!/usr/bin/env bats

setup() {
	source "$BATS_TEST_DIRNAME/test_helper.bash"
}

# -- _tmux_session_name ---------------------------------------------------

@test "_tmux_session_name: derives workspace/project from path" {
	run _tmux_session_name "/home/user/Projects/github.com/org/repo"
	[[ "$output" = "org/repo" ]]
}

@test "_tmux_session_name: replaces dots with underscores" {
	run _tmux_session_name "/home/user/Projects/github.com/user/my.project"
	[[ "$output" = "user/my_project" ]]
}

@test "_tmux_session_name: handles trailing slash" {
	run _tmux_session_name "/home/user/Projects/github.com/org/repo/"
	[[ "$output" = "org/repo" ]]
}

# -- _tmux_get_option ------------------------------------------------------

@test "_tmux_get_option: returns default when tmux returns empty" {
	run _tmux_get_option "@nonexistent" "fallback"
	[[ "$output" = "fallback" ]]
}

@test "_tmux_get_option: returns empty when no default provided" {
	run _tmux_get_option "@nonexistent"
	[[ "$output" = "" ]]
}
