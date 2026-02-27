#!/bin/bash
# Shared functions for Chima scripts.

# Source colors:
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$LIB_DIR/colors.sh"

# Check if running on Arch Linux:
check_arch_linux() {
    if [[ ! -f /etc/arch-release ]]; then
        print_error "System is not running Arch Linux."
        exit 1
    fi
}

# Check internet connectivity:
check_internet() {
    if ! ping -c 1 archlinux.org &> /dev/null; then
        print_error "Internet connection not detected."
        print_info "Please connect to the internet and try again."
        exit 1
    fi
    print_success "Internet connection detected successfully."
}

# Check disk space (requires at least specified GB free):
check_disk_space() {
    local required_gb=$1
    local available_kb=$(df / | tail -1 | awk '{print $4}')
    local available_gb=$((available_kb / 1024 / 1024))

    if [[ $available_gb -lt $required_gb ]]; then
        print_error "Insufficient disk space. Required: ${required_gb}GB, Available: ${available_gb}GB."
        exit 1
    fi
    print_success "Sufficient disk space available: ${available_gb}GB."
}

# Initialize PGP keys:
init_pgp_keys() {
    print_step "Initializing PGP keys..."

    if ! sudo pacman-key --init &> /dev/null; then
        print_warning "PGP key initialization had issues, continuing..."
    fi

    if ! sudo pacman-key --populate archlinux &> /dev/null; then
        print_warning "PGP key population had issues, continuing..."
    fi

    if ! timeout 60 sudo pacman-key --refresh-keys &> /dev/null; then
        print_warning "PGP key refresh timed out or failed, continuing..."
    fi

    print_success "PGP keys initialized."
}

install_package() {
    local pkg=$1
    local max_retries=3
    local timeout=180
    local retries=$max_retries

    while [[ $retries -gt 0 ]]; do
        if timeout $timeout sudo pacman -S --noconfirm --needed "$pkg" 2>&1; then
            return 0
        else
            retries=$((retries - 1))
            if [[ $retries -gt 0 ]]; then
                print_warning "Failed to install $pkg, retrying... ($retries/$max_retries)"
                sleep 5
            fi
        fi
    done

    print_error "Failed to install $pkg after $max_retries attempts."
    return 1
}

install_aur_package() {
    local pkg=$1
    local max_retries=3
    local timeout=300
    local retries=$max_retries
    local success=false

    while [[ $retries -gt 0 ]] && [[ "$success" = false ]]; do
        yay -S --noconfirm --needed "$pkg" 2>&1 | tee /tmp/yay_output.log
        local exit_code=${PIPESTATUS[0]}

        if [[ $exit_code -eq 0 ]]; then
            return 0
        else
            if grep -q "429\|rate limit\|too many requests" /tmp/yay_output.log; then
                retries=$((retries - 1))
                if [[ $retries -gt 0 ]]; then
                    print_warning "Rate limited. Waiting 30s before retry ($retries left)..."
                    sleep 30
                fi
            else
                print_error "Failed to install $pkg due to an error other than rate limiting."
                return 1
            fi
        fi
    done

    print_error "Failed to install $pkg after $max_retries attempts (Rate limited)."
    return 1
}

ensure_directory() {
    local dir=$1
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
    fi
}

copy_with_backup() {
    local src=$1
    local dest=$2

    if [[ -f "$dest" ]]; then
        local backup="${dest}.backup.$(date +%Y%m%d_%H%M%S)"
        print_info "Backing up existing file to $backup."
        cp "$dest" "$backup"
    fi

    cp "$src" "$dest"
}

copy_dir_with_backup() {
    local src=$1
    local dest=$2

    if [[ -d "$dest" ]]; then
        local backup="${dest}.backup.$(date +%Y%m%d_%H%M%S)"
        print_info "Backing up existing directory to $backup."
        cp -r "$dest" "$backup"
    fi

    cp -r "$src" "$dest"
}

enable_service() {
    local service=$1
    local is_user_service=$2

    if [[ "$is_user_service" == "user" ]]; then
        if systemctl --user enable "$service" &> /dev/null; then
            print_success "Enabled user service: $service."
        else
            print_warning "Failed to enable user service: $service."
        fi
    else
        if sudo systemctl enable "$service" &> /dev/null; then
            print_success "Enabled system service: $service."
        else
            print_warning "Failed to enable system service: $service."
        fi
    fi
}

start_service() {
    local service=$1
    local is_user_service=$2

    if [[ "$is_user_service" == "user" ]]; then
        if systemctl --user start "$service" &> /dev/null; then
            print_success "Started user service: $service."
        else
            print_warning "Failed to start user service: $service."
        fi
    else
        if sudo systemctl start "$service" &> /dev/null; then
            print_success "Started system service: $service."
        else
            print_warning "Failed to start system service: $service."
        fi
    fi
}

set_permissions() {
    local file=$1
    local perms=$2
    chmod "$perms" "$file"
}

set_ownership() {
    local file=$1
    local owner=$2
    local group=$3
    chown "${owner}:${group}" "$file"
}

ask_yes_no() {
    local question=$1
    local default=${2:-"y"}
    local prompt
    local answer

    if [[ "$default" == "y" ]]; then
        prompt="[Y/n]"
    else
        prompt="[y/N]"
    fi

    while true; do
        read -p "$question $prompt " answer

        if [[ -z "$answer" ]]; then
            answer=$default
        fi

        answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')

        case $answer in
            y|yes ) return 0;;
            n|no ) return 1;;
            * ) echo "Please answer 'yes' or 'no'.";;
        esac
    done
}

get_username() {
    echo "$USER"
}

get_home_dir() {
    echo "$HOME"
}

command_exists() {
    command -v "$1" &> /dev/null
}

press_any_key() {
    read -n 1 -s -r -p "Press any key to continue..."
    echo
}

get_terminal_width() {
    local width=$(tput cols 2>/dev/null || echo 80)
    echo "$width"
}

draw_box() {
    local text=$1
    local width=${2:-$(get_terminal_width)}

    if [[ $width -lt 40 ]]; then
        width=40
    fi

    local text_length=${#text}
    local total_padding=$((width - text_length - 2))
    local left_padding=$((total_padding / 2))
    local right_padding=$((total_padding - left_padding))

    echo -e "${CYAN}╔$(printf '═%.0s' $(seq 1 $((width - 2))))╗${NC}"

    printf "${CYAN}║${NC}%*s${BRIGHT_CYAN}%s${NC}%*s${CYAN}║${NC}\n" \
        $left_padding "" "$text" $right_padding ""

    echo -e "${CYAN}╚$(printf '═%.0s' $(seq 1 $((width - 2))))╝${NC}"
}

# Clear screen helper:
clear_screen() {
    clear
}

show_menu() {
    local title=$1
    shift
    local options=("$@")
    local selected=0
    local key=""

    while true; do
        clear
        print_section "INSTALLATION MODE"
        echo -e "${BRIGHT_CYAN}${title}${NC}\n"

        for i in "${!options[@]}"; do
            if [[ $i -eq $selected ]]; then
                echo -e "${GOLD}> ${options[$i]}${NC}"
            else
                echo -e "  ${options[$i]}"
            fi
        done

        echo -e "\n${CYAN}Use ↑↓ arrows to navigate. Press 'Enter' to select.${NC}"

        IFS= read -rsn1 key

        if [[ $key == $'\x1b' ]]; then
            read -rsn1 -t 0.1 next_char
            if [[ $next_char == '[' ]]; then
                read -rsn1 -t 0.1 arrow
                key="$arrow"
            fi
        fi

        case "$key" in
            A) selected=$((selected - 1)) ;;
            B) selected=$((selected + 1)) ;;
            C) selected=$((selected + 1)) ;;
            D) selected=$((selected - 1)) ;;
            k) selected=$((selected - 1)) ;;
            j) selected=$((selected + 1)) ;;
            '') # Enter
                return $selected
                ;;
        esac

        if [[ $selected -lt 0 ]]; then
            selected=$((${#options[@]} - 1))
        elif [[ $selected -ge ${#options[@]} ]]; then
            selected=0
        fi
    done
}

show_multiselect() {
    local title=$1
    shift
    local options=("$@")
    local selected=0
    local -a checked=()
    local key=""

    for i in "${!options[@]}"; do
        checked[$i]=0
    done

    while true; do
        clear >&2
        print_section "OPTIONAL PACKAGES" >&2
        echo -e "${BRIGHT_CYAN}${title}${NC}\n" >&2

        for i in "${!options[@]}"; do
            local checkbox="[ ]"
            if [[ ${checked[$i]} -eq 1 ]]; then
                checkbox="${GOLD}[X]${NC}"
            fi

            if [[ $i -eq $selected ]]; then
                echo -e "${GOLD}>${NC} $checkbox ${options[$i]}" >&2
            else
                echo -e "  $checkbox ${options[$i]}" >&2
            fi
        done

        echo -e "\n${CYAN}Press 'Space' to toggle. 'Enter' to confirm. 'a' to select all. 'n' to select none.${NC}" >&2

        IFS= read -rsn1 key

        if [[ $key == $'\x1b' ]]; then
            read -rsn1 -t 0.1 next_char
            if [[ $next_char == '[' ]]; then
                read -rsn1 -t 0.1 arrow
                key="$arrow"
            fi
        fi

        case "$key" in
            A) selected=$((selected - 1)) ;;
            B) selected=$((selected + 1)) ;;
            C) selected=$((selected + 1)) ;;
            D) selected=$((selected - 1)) ;;
            k) selected=$((selected - 1)) ;;
            j) selected=$((selected + 1)) ;;
            ' ') # Space
                if [[ ${checked[$selected]} -eq 1 ]]; then
                    checked[$selected]=0
                else
                    checked[$selected]=1
                fi
                ;;
            'a') # Select all
                for i in "${!options[@]}"; do
                    checked[$i]=1
                done
                ;;
            'n') # Select none
                for i in "${!options[@]}"; do
                    checked[$i]=0
                done
                ;;
            '') # Enter - Confirm selection
                local result=""
                for i in "${!checked[@]}"; do
                    if [[ ${checked[$i]} -eq 1 ]]; then
                        if [[ -z "$result" ]]; then
                            result="$i"
                        else
                            result="$result,$i"
                        fi
                    fi
                done
                echo "$result"
                return 0
                ;;
        esac

        if [[ $selected -lt 0 ]]; then
            selected=$((${#options[@]} - 1))
        elif [[ $selected -ge ${#options[@]} ]]; then
            selected=0
        fi
    done
}

show_progress() {
    local current=$1
    local total=$2
    local term_width=$(get_terminal_width)

    local width=$((term_width - 10))

    if [[ $width -lt 20 ]]; then
        width=20
    elif [[ $width -gt 100 ]]; then
        width=100
    fi

    local percentage=$((current * 100 / total))
    local filled=$((width * current / total))
    local empty=$((width - filled))

    printf "\r${CYAN}["
    printf "${GREEN}%${filled}s" | tr ' ' '█'
    printf "${CYAN}%${empty}s" | tr ' ' '░'
    printf "] ${WHITE}%3d%%${NC}" $percentage
}

show_spinner() {
    local pid=$1
    local message=$2
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local temp

    tput civis

    while kill -0 "$pid" 2>/dev/null; do
        temp=${spinstr#?}
        printf "\r${CYAN}%c${NC} ${message}" "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep 0.1
    done

    tput cnorm
    printf "\r${GREEN}[DONE]${NC} ${message}\n"
}

install_packages_with_progress() {
    local -n packages=$1
    local package_manager=${2:-"pacman"}
    local total=${#packages[@]}
    local current=0
    local failed_packages=()

    echo -e "\n${CYAN}Installing ${total} packages...${NC}\n"

    for pkg in "${packages[@]}"; do
        ((current++))
        echo -e "${CYAN}[$current/$total]${NC} Installing ${YELLOW}$pkg${NC}..."

        if [[ "$package_manager" == "pacman" ]]; then
            if ! install_package "$pkg"; then
                failed_packages+=("$pkg")
            fi
        elif [[ "$package_manager" == "yay" ]]; then
            if ! install_aur_package "$pkg"; then
                failed_packages+=("$pkg")
            fi
        fi

        show_progress "$current" "$total"
        echo ""
    done

    echo -e "\n"

    if [[ ${#failed_packages[@]} -gt 0 ]]; then
        print_warning "Failed to install ${#failed_packages[@]} packages:"
        for pkg in "${failed_packages[@]}"; do
            echo -e "  ${RED}[FAIL]${NC} $pkg"
        done
        return 1
    else
        print_success "Packages installed successfully."
        return 0
    fi
}

confirm_action() {
    local message=$1
    local default=${2:-"n"}

    echo -e ""
    ask_yes_no "${message}" "$default"
}

show_summary() {
    local -n summary_items=$1

    clear
    draw_box "INSTALLATION SUMMARY"
    echo ""

    for item in "${summary_items[@]}"; do
        echo -e "  ${GREEN}[OK]${NC} $item"
    done

    echo ""
    press_any_key
}

print_section() {
    local title=$1
    local width=$(get_terminal_width)

    if [[ $width -lt 40 ]]; then
        width=40
    fi

    local separator=$(printf '━%.0s' $(seq 1 $width))

    echo -e "\n${BRIGHT_CYAN}${separator}${NC}"
    echo -e "${BRIGHT_CYAN}  $title${NC}"
    echo -e "${BRIGHT_CYAN}${separator}${NC}\n"
}
