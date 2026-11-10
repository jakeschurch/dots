---
name: new-remote-session
description: >
  Create a new agent-deck session with sonnet model, claude-in-chrome enabled, and /remote-control
  activated. Use when user says "new remote session", "create remote session", "new session",
  or invokes /new-remote-session. Takes optional title and path arguments.
---

Create a new agent-deck session with claude-in-chrome and remote control enabled.

## Usage

`/new-remote-session [title] [path]`

- `title` — session name (default: basename of path)
- `path` — project directory (default: current directory)

## Steps

Run these commands in order:

**1. Create the session** (use provided title/path, or prompt user if missing):

```bash
agent-deck add -no-parent -t "<TITLE>" -c claude <PATH>
```

**2. Start with `/remote-control` as initial message:**

```bash
agent-deck session start -m "/remote-control" "<TITLE>"
```

**3. Confirm** by running `agent-deck status` and reporting the session is running.

## Notes

- `-no-parent` makes it a peer session, not a sub-agent
- `-m "/remote-control"` sends the slash command at start — avoids race condition vs `session send` on a fresh session
- If `/remote-control` doesn't activate, tell user to attach and run it manually
