#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/colors.sh"
source "$SCRIPT_DIR/lib/functions.sh"

echo "Testing single-select menu..."
sleep 1

print_section "TEST MENU"

options=(
    "Option 1"
    "Option 2"
    "Option 3"
)

show_menu "Select an option:" "${options[@]}"
choice=$?

echo ""
echo "You selected: $choice (${options[$choice]})"
