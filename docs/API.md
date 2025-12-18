# tmux-fzf API Documentation

This document describes the public API for the tmux-fzf plugin.

## Table of Contents

- [Core Functions](#core-functions)
  - [check_dependencies](#check_dependencies)
  - [tmux_switch_to](#tmux_switch_to)
  - [tmux_has_session](#tmux_has_session)
  - [tmux_new_session](#tmux_new_session)
  - [tmux_session_name](#tmux_session_name)
- [Project Functions](#project-functions)
  - [tmux_session_project](#tmux_session_project)
- [Session Functions](#session-functions)
  - [tmux_session_open](#tmux_session_open)

---

## Core Functions

Located in `scripts/core.sh`.

### check_dependencies

Check if required dependencies are installed.

Verifies that fzf and fd are installed and available in the system PATH.
If any dependency is not found, displays an error message and exits with status 1.

```bash
check_dependencies
```

**Arguments:**
- None

**Returns:**
- `0` if all dependencies are installed
- `1` if any dependency is missing

---

### tmux_switch_to

Switch to a given tmux session.

Switches the current tmux client to the specified session.

```bash
tmux_switch_to "session_name"
```

**Arguments:**
- `$1` - The name of the tmux session to switch to

**Returns:**
- `0` on success, non-zero on failure

---

### tmux_has_session

Check if a tmux session exists.

Determines whether a tmux session with the given name is currently running.

```bash
tmux_has_session "session_name"
```

**Arguments:**
- `$1` - The name of the tmux session to check

**Returns:**
- `0` if the session exists
- `1` if the session does not exist

---

### tmux_new_session

Create a new tmux session.

Creates a new detached tmux session with the specified name and working directory.

```bash
tmux_new_session "session_name" "/path/to/directory"
```

**Arguments:**
- `$1` - The name for the new tmux session
- `$2` - The working directory path for the session

**Returns:**
- `0` on success, non-zero on failure

---

### tmux_session_name

Derive a session name from a directory path.

Generates a tmux session name by combining the workspace (parent directory)
and project (directory name) with a forward slash, and replacing dots with
underscores to ensure tmux compatibility.

```bash
tmux_session_name "/path/to/project"
# Output: "to/project"
```

**Arguments:**
- `$1` - The directory path to derive the session name from

**Outputs:**
- The generated session name in the format "workspace/project"

**Returns:**
- `0` on success

---

## Project Functions

Located in `scripts/tmux-fzf-project.sh`.

### tmux_session_project

Create or switch to a tmux session for a project directory.

If a directory path is provided as an argument, creates or switches to a session
for that directory. Otherwise, presents an fzf menu to select a project directory
from the configured projects path. The fzf menu includes a ctrl-o binding to open
the selected project's GitHub repository in the browser using the gh CLI.

By default, only directories containing a .git subdirectory are shown. This can
be disabled by setting `@tmux-fzf-projects-git-only` to "false".

```bash
# With argument
tmux_session_project "/path/to/project"

# Without argument (opens fzf picker)
tmux_session_project
```

**Arguments:**
- `$1` - (Optional) The directory path to create/switch to a session for

**Returns:**
- `0` on success or if no directory was selected

**Dependencies:**
- `fzf`: for interactive directory selection
- `fd`: for fast directory traversal
- `gh`: (optional) for opening GitHub repositories with ctrl-o

**Configuration:**
- `@tmux-fzf-projects-path`: Base path for project directories (default: `$HOME/Projects`)
- `@tmux-fzf-projects-git-only`: Only show git repositories (default: `true`)

---

## Session Functions

Located in `scripts/tmux-fzf-session.sh`.

### tmux_session_open

Open an existing tmux session using fzf selection.

Presents an fzf menu of all running tmux sessions and switches to the selected one.

**Key Bindings:**
- `ctrl-x`: Kill the highlighted session and reload the list
- `space`: Jump mode for quick navigation
- `jump`: Accept selection after jump

```bash
tmux_session_open
```

**Arguments:**
- None

**Returns:**
- `0` on success or if no session was selected

**Dependencies:**
- `fzf`: for interactive session selection
