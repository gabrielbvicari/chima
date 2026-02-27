#!/bin/bash
# Workspace application launcher script

WORKSPACE="$1"
APP_COMMAND="$2"
APP_CLASS="$3"

# Check if app is already running anywhere
APP_RUNNING=$(hyprctl clients | grep -i "class:.*$APP_CLASS")

if [ -z "$APP_RUNNING" ]; then
    # Switch to workspace FIRST, then launch app
    hyprctl dispatch workspace "$WORKSPACE"

    # Wait for workspace switch animation to complete
    sleep 0.15

    # Launch app in the current (target) workspace
    eval "$APP_COMMAND" &
else
    # App is running, get its current workspace and window address
    CURRENT_WORKSPACE=$(echo "$APP_RUNNING" | grep -o "workspace: [0-9]*" | head -1 | cut -d' ' -f2)
    WINDOW_ADDRESS=$(echo "$APP_RUNNING" | grep -B5 "class:.*$APP_CLASS" | grep "Window" | head -1 | cut -d' ' -f2)
    
    if [ "$CURRENT_WORKSPACE" != "$WORKSPACE" ]; then
        # Move the specific window to the desired workspace
        hyprctl dispatch movetoworkspacesilent "$WORKSPACE,address:$WINDOW_ADDRESS"
    fi
    
    # Switch to the workspace and focus the window
    hyprctl dispatch workspace "$WORKSPACE"
    if [ -n "$WINDOW_ADDRESS" ]; then
        hyprctl dispatch focuswindow "address:$WINDOW_ADDRESS"
    fi
fi
