#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/colors.sh"
source "$SCRIPT_DIR/lib/functions.sh"

echo "Starting multiselect test..."
sleep 1

options=(
    "GitHub CLI (gh - for GitHub operations)"
    "Google Cloud CLI (gcloud, bq, gsutil, etc.)"
    "pCloud Drive (cloud storage sync)"
    "Claude Code (AI coding assistant)"
)

echo "Options array has ${#options[@]} items"
sleep 2

selected=$(show_multiselect "Test Title:" "${options[@]}")

echo ""
echo "Result: $selected"
