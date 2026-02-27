#!/usr/bin/env bash

# Hyprland settings manager
# Manages Hyprland appearance and behavior settings

HYPRLAND_CONF="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/custom/general.conf"
SCRIPT_LOG="/tmp/hyprland-settings.log"

log() {
    echo "[$(date '+%H:%M:%S')] $*" >> "$SCRIPT_LOG"
}

# Function to update a nested config value
update_nested_setting() {
    local setting_path="$1"  # e.g., "decoration.blur.size"
    local value="$2"

    log "=== UPDATE REQUESTED: $setting_path = $value ==="

    if [ ! -f "$HYPRLAND_CONF" ]; then
        log "ERROR: File not found at $HYPRLAND_CONF"
        echo "Error: general.conf not found at $HYPRLAND_CONF" >&2
        return 1
    fi

    # Check if file is empty
    if [ ! -s "$HYPRLAND_CONF" ]; then
        log "ERROR: File is empty"
        echo "Error: $HYPRLAND_CONF is empty" >&2
        return 1
    fi

    local file_size_before=$(stat -c%s "$HYPRLAND_CONF")
    log "File size before: $file_size_before bytes"

    # Create backup
    cp "$HYPRLAND_CONF" "$HYPRLAND_CONF.bak"
    log "Backup created"

    # Split the path into components
    IFS='.' read -ra path_parts <<< "$setting_path"
    local setting_name="${path_parts[-1]}"
    local nesting_level="${#path_parts[@]}"

    log "Nesting level: $nesting_level, setting: $setting_name"

    # Determine the correct sed pattern based on nesting level
    if [[ "$nesting_level" -eq 1 ]]; then
        # Top-level setting - NOT IMPLEMENTED YET
        log "ERROR: Top-level settings not supported"
        return 1

    elif [[ "$nesting_level" -eq 2 ]]; then
        # First-level nested setting (e.g., "rounding" in "decoration")
        local block="${path_parts[0]}"
        log "Updating ${block}.${setting_name}"

        # Use improved awk with proper depth tracking and validation
        awk -v block="$block" -v setting="$setting_name" -v value="$value" '
        BEGIN {
            in_block=0
            found=0
            depth=0
        }

        # Track brace depth
        /{/ { depth++ }
        /}/ {
            depth--
            if (depth == 0) { in_block=0 }
        }

        # Enter main block
        !in_block && $0 ~ "^"block" \\{$" {
            in_block=1
            depth=1
        }

        # Update the setting (only in correct block, only once)
        in_block && !found && $0 ~ "^    "setting" = " {
            $0 = "    "setting" = "value
            found=1
        }

        { print }

        END {
            if (!found) {
                print "ERROR: Setting '"'"'"block"."setting"'"'"' not found in config" > "/dev/stderr"
                exit 1
            }
        }
        ' "$HYPRLAND_CONF" > "$HYPRLAND_CONF.tmp"

        # Check if awk failed
        if [ $? -ne 0 ]; then
            log "ERROR: Setting not found or awk failed"
            rm -f "$HYPRLAND_CONF.tmp"
            return 1
        fi

        # Validate temp file
        if [ ! -s "$HYPRLAND_CONF.tmp" ]; then
            log "ERROR: awk produced empty file"
            rm -f "$HYPRLAND_CONF.tmp"
            return 1
        fi

        mv "$HYPRLAND_CONF.tmp" "$HYPRLAND_CONF"

    elif [[ "$nesting_level" -eq 3 ]]; then
        # Second-level nested setting (e.g., "size" in "decoration.blur")
        local block="${path_parts[0]}"
        local subblock="${path_parts[1]}"
        log "Updating ${block}.${subblock}.${setting_name}"

        # Use improved awk with proper depth tracking and validation
        awk -v block="$block" -v subblock="$subblock" -v setting="$setting_name" -v value="$value" '
        BEGIN {
            in_block=0
            in_subblock=0
            found=0
            depth=0
        }

        # Track brace depth
        /{/ { depth++ }
        /}/ {
            depth--
            if (depth == 0) { in_block=0 }
            if (depth == 1 && in_block) { in_subblock=0 }
        }

        # Enter main block
        !in_block && $0 ~ "^"block" \\{$" {
            in_block=1
            depth=1
        }

        # Enter subblock (only if we are in main block)
        in_block && !in_subblock && $0 ~ "^    "subblock" \\{$" {
            in_subblock=1
        }

        # Update the setting (only in correct subblock, only once)
        in_subblock && !found && $0 ~ "^        "setting" = " {
            $0 = "        "setting" = "value
            found=1
        }

        { print }

        END {
            if (!found) {
                print "ERROR: Setting '"'"'"block"."subblock"."setting"'"'"' not found in config" > "/dev/stderr"
                exit 1
            }
        }
        ' "$HYPRLAND_CONF" > "$HYPRLAND_CONF.tmp"

        # Check if awk failed
        if [ $? -ne 0 ]; then
            log "ERROR: Setting not found or awk failed"
            rm -f "$HYPRLAND_CONF.tmp"
            cp "$HYPRLAND_CONF.bak" "$HYPRLAND_CONF"
            return 1
        fi

        # Validate that the temp file has content
        if [ ! -s "$HYPRLAND_CONF.tmp" ]; then
            log "ERROR: awk produced empty file"
            rm -f "$HYPRLAND_CONF.tmp"
            cp "$HYPRLAND_CONF.bak" "$HYPRLAND_CONF"
            return 1
        fi

        mv "$HYPRLAND_CONF.tmp" "$HYPRLAND_CONF"
    else
        log "ERROR: Nesting level $nesting_level not supported"
        return 1
    fi

    # Final validation: make sure file still has content
    if [ ! -s "$HYPRLAND_CONF" ]; then
        log "ERROR: Final file is empty! Restoring backup"
        cp "$HYPRLAND_CONF.bak" "$HYPRLAND_CONF"
        return 1
    fi

    local file_size_after=$(stat -c%s "$HYPRLAND_CONF")
    log "File size after: $file_size_after bytes"

    if [ "$file_size_after" -lt 100 ]; then
        log "WARNING: File suspiciously small ($file_size_after bytes). Restoring backup"
        cp "$HYPRLAND_CONF.bak" "$HYPRLAND_CONF"
        return 1
    fi

    log "SUCCESS: Updated $setting_path = $value"
    return 0
}

# Main script logic
case "${1}" in
    --set)
        if [ $# -lt 3 ]; then
            echo "Usage: $0 --set <setting_path> <value>" >&2
            exit 1
        fi
        setting_path="$2"
        value="$3"

        # Update config file for persistence
        update_nested_setting "$setting_path" "$value"
        ;;

    *)
        echo "Hyprland Settings Manager" >&2
        echo "Usage: $0 --set <setting_path> <value>" >&2
        exit 1
        ;;
esac
