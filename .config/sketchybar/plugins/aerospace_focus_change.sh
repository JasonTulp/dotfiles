#!/bin/bash

# Get current focused workspace
CURRENT_WORKSPACE=$(aerospace list-workspaces --focused)

# Read the last known workspace from a temp file
LAST_WORKSPACE_FILE="/tmp/aerospace_last_workspace"
if [ -f "$LAST_WORKSPACE_FILE" ]; then
    LAST_WORKSPACE=$(cat "$LAST_WORKSPACE_FILE")
else
    LAST_WORKSPACE=""
fi

# Only trigger update if workspace actually changed
if [ "$CURRENT_WORKSPACE" != "$LAST_WORKSPACE" ] && [ -n "$LAST_WORKSPACE" ]; then
    sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE="$CURRENT_WORKSPACE" PREV_WORKSPACE="$LAST_WORKSPACE"
fi

# Save current workspace for next time
echo "$CURRENT_WORKSPACE" > "$LAST_WORKSPACE_FILE"
