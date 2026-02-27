#!/usr/bin/env bash

# Wallpaper management script for desktop, hyprlock, and SDDM
# Sets wallpapers across all three systems

HYPRLOCK_CONF="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/hyprlock.conf"
SDDM_CONFIG="/usr/share/sddm/themes/silent/configs/default.conf"
SDDM_BACKGROUNDS="/usr/share/sddm/themes/silent/backgrounds"

# Function to set hyprlock wallpaper
set_hyprlock_wallpaper() {
    local source_path="$1"
    local hyprlock_dir="${XDG_CONFIG_HOME:-$HOME/.config}/hypr"
    local dest_path="$hyprlock_dir/hyprlock-wallpaper.png"

    if [ ! -f "$HYPRLOCK_CONF" ]; then
        echo "Error: hyprlock.conf not found at $HYPRLOCK_CONF" >&2
        return 1
    fi

    if [ ! -f "$source_path" ]; then
        echo "Error: Source wallpaper not found: $source_path" >&2
        return 1
    fi

    # Create directory if it doesn't exist
    mkdir -p "$hyprlock_dir"

    # Remove old hyprlock wallpaper files with different extensions to avoid orphans
    rm -f "$hyprlock_dir"/hyprlock-wallpaper.* 2>/dev/null

    # Get source extension to check if conversion is needed
    local source_ext="${source_path##*.}"
    local source_ext_lower=$(echo "$source_ext" | tr '[:upper:]' '[:lower:]')

    # Convert to PNG format (ensures consistent format for matugen template)
    if [ "$source_ext_lower" = "png" ]; then
        # Already PNG, just copy
        cp "$source_path" "$dest_path"
        echo "Hyprlock wallpaper copied to: $dest_path"
    else
        # Convert to PNG using ImageMagick (prefer 'magick' over deprecated 'convert')
        if command -v magick &>/dev/null; then
            magick "$source_path" "$dest_path" 2>/dev/null
            echo "Hyprlock wallpaper converted to PNG: $dest_path"
        elif command -v convert &>/dev/null; then
            convert "$source_path" "$dest_path" 2>/dev/null
            echo "Hyprlock wallpaper converted to PNG: $dest_path"
        else
            # Fallback: copy as-is and warn
            echo "Warning: ImageMagick not found, copying without conversion" >&2
            cp "$source_path" "$dest_path"
            echo "Note: Install imagemagick for automatic format conversion (pacman -S imagemagick)" >&2
        fi
    fi

    echo "Hyprlock wallpaper set to: $dest_path"
}

# Function to set SDDM wallpaper
set_sddm_wallpaper() {
    local wallpaper_path="$1"

    if [ ! -f "$wallpaper_path" ]; then
        echo "Error: Wallpaper file not found: $wallpaper_path" >&2
        return 1
    fi

    # Extract filename from path
    local wallpaper_filename=$(basename "$wallpaper_path")

    # Copy wallpaper to SDDM backgrounds directory (requires sudo)
    if ! sudo cp "$wallpaper_path" "$SDDM_BACKGROUNDS/$wallpaper_filename" 2>/dev/null; then
        echo "Error: Failed to copy wallpaper to SDDM backgrounds directory (requires sudo)" >&2
        return 1
    fi

    # Update SDDM config to use the new wallpaper (requires sudo)
    if ! sudo sed -i "s|^background = .*|background = $wallpaper_filename|g" "$SDDM_CONFIG" 2>/dev/null; then
        echo "Error: Failed to update SDDM config (requires sudo)" >&2
        return 1
    fi

    echo "SDDM wallpaper set to: $wallpaper_filename"
}

# Function to get current wallpapers
get_wallpapers() {
    echo "=== Current Wallpapers ==="

    # Desktop wallpaper
    if [ -f "${XDG_CONFIG_HOME:-$HOME/.config}/chima/config.json" ]; then
        desktop_wall=$(jq -r '.background.wallpaperPath' "${XDG_CONFIG_HOME:-$HOME/.config}/chima/config.json" 2>/dev/null || echo "")
        echo "Desktop: $desktop_wall"
    fi

    # Hyprlock wallpaper
    if [ -f "$HYPRLOCK_CONF" ]; then
        hyprlock_wall=$(grep "^    path = " "$HYPRLOCK_CONF" | sed 's/.*path = //')
        echo "Hyprlock: $hyprlock_wall"
    fi

    # SDDM wallpaper
    if [ -f "$SDDM_CONFIG" ]; then
        sddm_wall=$(grep "^background = " "$SDDM_CONFIG" | head -1 | sed 's/background = //')
        echo "SDDM: $SDDM_BACKGROUNDS/$sddm_wall"
    fi
}

# Main script logic
case "${1}" in
    --set-all)
        # Set wallpaper for all systems
        if [ -z "$2" ]; then
            echo "Usage: $0 --set-all <wallpaper_path>" >&2
            exit 1
        fi
        wallpaper_path="$2"

        # Call the existing switchwall.sh for desktop wallpaper
        "${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/chima/scripts/colors/switchwall.sh" "$wallpaper_path"

        # Set hyprlock wallpaper
        set_hyprlock_wallpaper "$wallpaper_path"

        # Set SDDM wallpaper
        set_sddm_wallpaper "$wallpaper_path"
        ;;

    --set-hyprlock)
        if [ -z "$2" ]; then
            echo "Usage: $0 --set-hyprlock <wallpaper_path>" >&2
            exit 1
        fi
        set_hyprlock_wallpaper "$2"
        ;;

    --set-sddm)
        if [ -z "$2" ]; then
            echo "Usage: $0 --set-sddm <wallpaper_path>" >&2
            exit 1
        fi
        set_sddm_wallpaper "$2"
        ;;

    --get)
        get_wallpapers
        ;;

    *)
        echo "Wallpaper Manager - Set wallpapers for desktop, hyprlock, and SDDM" >&2
        echo "" >&2
        echo "Usage:" >&2
        echo "  $0 --set-all <wallpaper_path>      Set wallpaper for all systems" >&2
        echo "  $0 --set-hyprlock <wallpaper_path> Set wallpaper for hyprlock only" >&2
        echo "  $0 --set-sddm <wallpaper_path>     Set wallpaper for SDDM only" >&2
        echo "  $0 --get                           Show current wallpapers" >&2
        exit 1
        ;;
esac
