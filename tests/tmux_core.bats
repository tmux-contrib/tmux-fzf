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

# -- _tmux_vagrant_name ----------------------------------------------------

@test "_tmux_vagrant_name: combines directory basename and machine name" {
	run _tmux_vagrant_name "/home/user/Projects/system.d" "default"
	[[ "$output" = "system_d/default" ]]
}

@test "_tmux_vagrant_name: replaces colons with underscores" {
	run _tmux_vagrant_name "/home/user/web" "app:1"
	[[ "$output" = "web/app_1" ]]
}

# -- _vagrant_parse_status -------------------------------------------------

@test "_vagrant_parse_status: emits aligned column header, rows and ignores trailing prose" {
	run _vagrant_parse_status <<'STATUS'
id       name    provider  state   directory
-----------------------------------------------------------------------
a1b2c3d  default virtualbox running /home/user/app
e4f5a6b  web     parallels poweroff /home/user/other

The above shows information about all known Vagrant environments
on this machine.
STATUS
	[[ "${#lines[@]}" -eq 3 ]]
	[[ "${lines[0]}" = "ID       NAME     STATE     PROVIDER    DIRECTORY" ]]
	[[ "${lines[1]}" = "a1b2c3d  default  running   virtualbox  /home/user/app" ]]
	[[ "${lines[2]}" = "e4f5a6b  web      poweroff  parallels   /home/user/other" ]]
}

@test "_vagrant_parse_status: keeps directories containing spaces" {
	run _vagrant_parse_status <<'STATUS'
id       name    provider  state   directory
-----------------------------------------------------------------------
a1b2c3d  default virtualbox running /home/user/my project/box

STATUS
	[[ "${lines[1]}" = "a1b2c3d  default  running  virtualbox  /home/user/my project/box" ]]
}

@test "_vagrant_parse_status: produces no output, not even a header, when there are no boxes" {
	run _vagrant_parse_status <<'STATUS'
There are no active Vagrant environments on this computer! Or,
you haven't destroyed and recreated Vagrant environments that were
started with an older version of Vagrant.
STATUS
	[[ -z "$output" ]]
}

# -- _vagrant_ssh_command --------------------------------------------------

@test "_vagrant_ssh_command: running box connects directly" {
	run _vagrant_ssh_command "a1b2c3d" "running"
	[[ "$output" = "vagrant ssh a1b2c3d" ]]
}

@test "_vagrant_ssh_command: stopped box is started first" {
	run _vagrant_ssh_command "a1b2c3d" "poweroff"
	[[ "$output" == "vagrant up a1b2c3d || "*"; vagrant ssh a1b2c3d" ]]
}
