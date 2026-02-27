#!/bin/bash
# Color definitions for Chima scripts.

# ANSI color codes:
RED='\033[38;5;203m'
GREEN='\033[38;5;114m'
YELLOW='\033[38;5;214m'
BLUE='\033[38;5;75m'
BRIGHT_CYAN='\033[38;5;123m'
CYAN='\033[38;5;87m'
WHITE='\033[0;37m'
GOLD='\033[38;5;221m'
NC='\033[0m'

# Formatted output functions:
print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[ OK ]${NC}  $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC}  $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC}  $1"
}

print_step() {
    echo -e "${CYAN}=====>${NC}  $1"
}

print_header() {
    local title=$1
    local width=$(tput cols 2>/dev/null || echo 80)

    # Ensure minimum width:
    if [[ $width -lt 40 ]]; then
        width=40
    fi

    # Create separator line:
    local separator=$(printf '═%.0s' $(seq 1 $width))

    echo -e "\n${BRIGHT_CYAN}${separator}${NC}"
    echo -e "${BRIGHT_CYAN}  $title${NC}"
    echo -e "${BRIGHT_CYAN}${separator}${NC}\n"
}

print_progress() {
    local current=$1
    local total=$2
    local message=$3
    echo -e "${CYAN}[$current/$total]${NC} $message"
}
