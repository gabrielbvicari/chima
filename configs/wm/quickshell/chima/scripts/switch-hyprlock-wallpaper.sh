#!/usr/bin/env bash
# Hyprlock wallpaper switcher - Opens file dialog and sets hyprlock wallpaper

# Get wallpaper path from file dialog
cd "$(xdg-user-dir PICTURES)/Wallpapers/showcase" 2>/dev/null || \
cd "$(xdg-user-dir PICTURES)/Wallpapers" 2>/dev/null || \
cd "$(xdg-user-dir PICTURES)" || exit 1

wallpaper="$(kdialog --getopenfilename . --title 'Choose wallpaper')"

# Exit if no wallpaper selected
if [ -z "$wallpaper" ]; then
    echo "No wallpaper selected"
    exit 0
fi

# Call wallpaper-manager script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$SCRIPT_DIR/wallpaper-manager.sh" --set-hyprlock "$wallpaper"
