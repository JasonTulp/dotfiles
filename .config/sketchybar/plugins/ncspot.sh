#!/bin/bash
source "$CONFIG_DIR/plugins/colors.sh"

# Check if Spotify is running
if ! pgrep -x "Spotify" > /dev/null; then
    sketchybar --set ncspot drawing=off
    exit 0
fi

# Get Spotify status using osascript
STATE=$(osascript -e 'tell application "Spotify" to player state as string' 2>/dev/null)

if [ "$STATE" = "" ]; then
    sketchybar --set ncspot drawing=off
    exit 0
fi

if [ "$STATE" = "stopped" ]; then
    sketchybar --set ncspot drawing=on icon.color="$TEXT_GREY" label=""
    exit 0
fi

# Get track info
TRACK=$(osascript -e 'tell application "Spotify" to name of current track as string' 2>/dev/null)
ARTIST=$(osascript -e 'tell application "Spotify" to artist of current track as string' 2>/dev/null)

if [ "$STATE" = "playing" ]; then
    sketchybar --set ncspot drawing=on label="$TRACK - $ARTIST" icon.color="$TEXT_SPOTIFY_GREEN"
else
    sketchybar --set ncspot drawing=on label="$TRACK - $ARTIST" icon.color="$TEXT_GREY"
fi
