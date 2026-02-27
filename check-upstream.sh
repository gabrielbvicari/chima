#!/bin/bash
# Compare local files against END-4's upstream for cherry-picking.

set -eo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

REMOTE="end4"
BRANCH="main"

if ! git remote get-url "$REMOTE" &>/dev/null; then
    echo -e "${RED}Remote '$REMOTE' not found. Add it with:${NC}"
    echo "  git remote add $REMOTE git@github.com:end-4/dots-hyprland.git"
    exit 1
fi

UPSTREAM="$REMOTE/$BRANCH"

# Map of local paths to upstream paths (local:upstream)
MAPPINGS=(
    "configs/wm/quickshell/chima:dots/.config/quickshell/ii"
    "configs/wm/hyprland/hypr:dots/.config/hypr"
    "configs/theme/matugen:dots/.config/matugen"
    "configs/theme/Kvantum:dots/.config/Kvantum"
    "configs/theme/gtk-3.0:dots/.config/gtk-3.0"
    "configs/theme/gtk-4.0:dots/.config/gtk-4.0"
    "configs/shell/fish/fish:dots/.config/fish"
    "configs/terminal/kitty/kitty:dots/.config/kitty"
    "configs/apps/fuzzel:dots/.config/fuzzel"
    "configs/apps/wlogout:dots/.config/wlogout"
)

WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

fetch_upstream() {
    echo -e "${CYAN}Fetching $REMOTE/$BRANCH...${NC}"
    git fetch "$REMOTE" "$BRANCH" --quiet
}

show_help() {
    echo "Usage: $0 [options] [path-filter]"
    echo
    echo "Options:"
    echo "  -l, --list       List mapped paths only"
    echo "  -s, --summary    Show summary of changed files per mapping (default)"
    echo "  -d, --diff       Show full diffs"
    echo "  -f, --file FILE  Compare a specific file (local path)"
    echo "  -h, --help       Show this help"
    echo
    echo "Examples:"
    echo "  $0                          # Show summary of all changes"
    echo "  $0 -d quickshell            # Show diffs for quickshell files"
    echo "  $0 -f configs/wm/quickshell/chima/shell.qml"
}

find_upstream_path() {
    local local_file="$1"
    for mapping in "${MAPPINGS[@]}"; do
        local local_prefix="${mapping%%:*}"
        local upstream_prefix="${mapping##*:}"
        if [[ "$local_file" == "$local_prefix"* ]]; then
            local relative="${local_file#$local_prefix}"
            echo "${upstream_prefix}${relative}"
            return 0
        fi
    done
    return 1
}

# Extract upstream directory to a flat temp path
extract_upstream() {
    local upstream_prefix="$1"
    local dest="$2"
    local extract_tmp="$WORK_DIR/_extract_$$"
    mkdir -p "$extract_tmp"
    if ! git archive "$UPSTREAM" -- "$upstream_prefix" 2>/dev/null | tar -x -C "$extract_tmp" 2>/dev/null; then
        rm -rf "$extract_tmp"
        return 1
    fi
    if [ -d "$extract_tmp/$upstream_prefix" ]; then
        mv "$extract_tmp/$upstream_prefix" "$dest"
    fi
    rm -rf "$extract_tmp"
}

show_summary() {
    local filter="$1"
    local total_changed=0
    local total_new=0
    local total_identical=0
    local total_local_only=0

    for mapping in "${MAPPINGS[@]}"; do
        local local_prefix="${mapping%%:*}"
        local upstream_prefix="${mapping##*:}"

        if [ -n "$filter" ] && [[ "$local_prefix" != *"$filter"* ]]; then
            continue
        fi

        if [ ! -d "$local_prefix" ]; then
            echo -e "${RED}$local_prefix${NC} — local path not found"
            continue
        fi

        local tag
        tag=$(echo "$local_prefix" | tr '/' '_')
        local upstream_dir="$WORK_DIR/$tag"

        if ! extract_upstream "$upstream_prefix" "$upstream_dir" || [ ! -d "$upstream_dir" ]; then
            echo -e "${YELLOW}$local_prefix${NC} — not in upstream (local only)"
            continue
        fi

        local changed=0 new_upstream=0 identical=0 local_only=0
        local diff_output
        diff_output=$(diff -rq "$local_prefix" "$upstream_dir" 2>/dev/null) || true

        while IFS= read -r line; do
            [ -z "$line" ] && continue
            if [[ "$line" == "Files "* && "$line" == *" differ" ]]; then
                changed=$((changed + 1))
            elif [[ "$line" == "Only in $upstream_dir"* ]]; then
                new_upstream=$((new_upstream + 1))
            elif [[ "$line" == "Only in $local_prefix"* ]]; then
                local_only=$((local_only + 1))
            fi
        done <<< "$diff_output"

        # Count identical files
        local total_local
        total_local=$(find "$local_prefix" -type f 2>/dev/null | wc -l)
        identical=$((total_local - changed - local_only))
        [ "$identical" -lt 0 ] && identical=0

        if [ $((changed + new_upstream)) -gt 0 ]; then
            echo -e "${CYAN}$local_prefix${NC} ← ${upstream_prefix}"
            [ "$changed" -gt 0 ] && echo -e "  ${YELLOW}$changed changed${NC}"
            [ "$new_upstream" -gt 0 ] && echo -e "  ${GREEN}$new_upstream new in upstream${NC}"
            [ "$local_only" -gt 0 ] && echo -e "  $local_only local only"
            [ "$identical" -gt 0 ] && echo -e "  $identical identical"
            echo
        else
            echo -e "${GREEN}$local_prefix${NC} — up to date ($identical files)"
        fi

        total_changed=$((total_changed + changed))
        total_new=$((total_new + new_upstream))
        total_identical=$((total_identical + identical))
        total_local_only=$((total_local_only + local_only))
    done

    echo -e "─────────────────────────────────"
    echo -e "Total: ${YELLOW}$total_changed changed${NC}, ${GREEN}$total_new new${NC}, $total_local_only local only, $total_identical identical"
}

show_diffs() {
    local filter="$1"

    for mapping in "${MAPPINGS[@]}"; do
        local local_prefix="${mapping%%:*}"
        local upstream_prefix="${mapping##*:}"

        if [ -n "$filter" ] && [[ "$local_prefix" != *"$filter"* ]]; then
            continue
        fi

        if [ ! -d "$local_prefix" ]; then
            echo -e "${RED}$local_prefix${NC} — local path not found"
            continue
        fi

        local tag
        tag=$(echo "$local_prefix" | tr '/' '_')
        local upstream_dir="$WORK_DIR/$tag"

        if ! extract_upstream "$upstream_prefix" "$upstream_dir" || [ ! -d "$upstream_dir" ]; then
            echo -e "${YELLOW}$local_prefix${NC} — not in upstream (local only)"
            continue
        fi

        echo -e "${CYAN}=== $local_prefix ← $upstream_prefix ===${NC}"
        echo

        diff -ru "$local_prefix" "$upstream_dir" 2>/dev/null \
            | sed "s|$upstream_dir|upstream:$upstream_prefix|g" \
            || true

        echo
    done
}

compare_single_file() {
    local local_file="$1"
    local upstream_path
    upstream_path=$(find_upstream_path "$local_file") || {
        echo -e "${RED}No upstream mapping for: $local_file${NC}"
        exit 1
    }

    if ! git cat-file -e "$UPSTREAM:$upstream_path" 2>/dev/null; then
        echo -e "${RED}File not found in upstream: $upstream_path${NC}"
        exit 1
    fi

    echo -e "${YELLOW}--- $local_file (local)${NC}"
    echo -e "${CYAN}+++ $upstream_path (upstream)${NC}"
    diff <(cat "$local_file") <(git show "$UPSTREAM:$upstream_path") || true
}

# Parse arguments
MODE="summary"
FILTER=""
SINGLE_FILE=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -l|--list)
            for mapping in "${MAPPINGS[@]}"; do
                local_prefix="${mapping%%:*}"
                upstream_prefix="${mapping##*:}"
                echo -e "${CYAN}$local_prefix${NC} ← $upstream_prefix"
            done
            exit 0
            ;;
        -s|--summary) MODE="summary"; shift ;;
        -d|--diff) MODE="diff"; shift ;;
        -f|--file) SINGLE_FILE="$2"; shift 2 ;;
        -h|--help) show_help; exit 0 ;;
        *) FILTER="$1"; shift ;;
    esac
done

if [ -n "$SINGLE_FILE" ]; then
    fetch_upstream
    compare_single_file "$SINGLE_FILE"
elif [ "$MODE" = "diff" ]; then
    fetch_upstream
    show_diffs "$FILTER"
else
    fetch_upstream
    show_summary "$FILTER"
fi
