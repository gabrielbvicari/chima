#!/bin/bash
# System Update Script For Arch Linux (Chima).

set -e

sudo -v

while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

QUICKSHELL_UPDATED=false
GRUB_UPDATED=false
KERNEL_UPDATED=false

echo "[1/7] Checking for updates..."

checkupdates_output=$(checkupdates 2>/dev/null || true)
aur_updates=$(yay -Qua 2>/dev/null || true)

UPDATES_AVAILABLE=false

if [ -z "$checkupdates_output" ] && [ -z "$aur_updates" ]; then
    echo -e "${GREEN}No package updates available.${NC}"
else
    UPDATES_AVAILABLE=true
    echo "Updates available:"
    [ -n "$checkupdates_output" ] && echo "$checkupdates_output" | head -20
    [ -n "$aur_updates" ] && echo "$aur_updates" | head -10
fi

if echo "$aur_updates" | grep -q "quickshell-git"; then
    QUICKSHELL_UPDATED=true
fi

if echo "$checkupdates_output" | grep -qE "^qt6|^hyprland"; then
    QUICKSHELL_UPDATED=true
fi

if echo "$checkupdates_output" | grep -q "^grub "; then
    GRUB_UPDATED=true
fi

if echo "$checkupdates_output" | grep -q "^linux "; then
    KERNEL_UPDATED=true
fi

if [ "$UPDATES_AVAILABLE" = true ]; then
    echo ""
    echo "Verifying package availability..."

    if [ -n "$aur_updates" ]; then
        echo "Testing AUR package availability..."
        TEST_FAILED=false
        for pkg in $(echo "$aur_updates" | head -3 | awk '{print $1}'); do
            if ! yay -Si "$pkg" >/dev/null 2>&1; then
                echo -e "${YELLOW}Warning: $pkg may not be available.${NC}"
                TEST_FAILED=true
            fi
        done
        if [ "$TEST_FAILED" = true ]; then
            echo -e "${YELLOW}Some AUR packages may fail.${NC}"
        fi
    fi

    echo ""
    read -p "Continue with update? (y/N) " -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Update cancelled."
        exit 1
    fi
else
    echo "Proceeding with system maintenance tasks..."
fi

echo ""
echo "[2/7] Creating backup..."

if [ -f ~/backup-system.sh ]; then
    ~/backup-system.sh
    echo -e "${GREEN}Backup created.${NC}"
else
    echo -e "${YELLOW}Backup script not found. Skipping backup...${NC}"
fi

if [ "$UPDATES_AVAILABLE" = true ]; then
    echo ""
    echo "[3/7] Updating official packages..."

    if sudo pacman -Syyuu --noconfirm; then
        echo -e "${GREEN}Official packages updated.${NC}"
    else
        echo -e "${YELLOW}Some official packages failed to update. Continuing...${NC}"
    fi

    echo ""
    echo "[4/7] Updating AUR packages..."

    if yay -Syyuu --noconfirm; then
        echo -e "${GREEN}AUR packages updated.${NC}"
    else
        echo -e "${YELLOW}Some AUR packages failed. Checking for failed packages...${NC}"

        failed_packages=""
        for pkg in $(echo "$aur_updates" | awk '{print $1}'); do
            if ! pacman -Q "$pkg" >/dev/null 2>&1 || yay -Qu "$pkg" 2>/dev/null | grep -q "$pkg"; then
                failed_packages="$failed_packages $pkg"
            fi
        done

        if [ -n "$failed_packages" ]; then
            echo "Retrying failed packages with delays..."
            for pkg in $failed_packages; do
                echo "Attempting $pkg..."
                retries=3
                success=false

                while [ $retries -gt 0 ] && [ "$success" = false ]; do
                    if yay -S --noconfirm "$pkg" 2>&1 | tee /tmp/yay_output.txt; then
                        echo -e "${GREEN}Package $pkg installed.${NC}"
                        success=true
                    else
                        if grep -q "429\|rate limit\|too many requests" /tmp/yay_output.txt; then
                            retries=$((retries-1))
                            if [ $retries -gt 0 ]; then
                                echo -e "${YELLOW}Rate limited. Waiting 30s before retry ($retries left)...${NC}"
                                sleep 30
                            else
                                echo -e "${RED}Package $pkg failed after 3 attempts (rate limited).${NC}"
                            fi
                        else
                            echo -e "${RED}Package $pkg failed (non-rate-limit error).${NC}"
                            break
                        fi
                    fi
                done
            done
            rm -f /tmp/yay_output.txt
        fi
    fi
else
    echo ""
    echo "[3/7] Updating official packages... No updates."
    echo ""
    echo "[4/7] Updating AUR packages... No updates."
fi

echo ""
echo "[5/7] Updating Flatpak packages..."

if command -v flatpak &> /dev/null; then
    flatpak update -y
    echo -e "${GREEN}Flatpak packages updated.${NC}"
else
    echo "Flatpak not installed. Skipping update..."
fi

echo ""
echo "[6/7] Running post-update maintenance..."

if [ "$QUICKSHELL_UPDATED" = true ]; then
    echo "Recompiling Quickshell..."
    if yay -S quickshell-git --rebuild --noconfirm; then
        echo -e "${GREEN}Quickshell rebuild successful.${NC}"

        echo "Restarting Quickshell service..."
        systemctl --user stop quickshell 2>/dev/null || true

        pkill -u $USER quickshell 2>/dev/null || true
        sleep 1

        systemctl --user start quickshell 2>/dev/null || true
        sleep 2

        echo "Performing health check..."
        if systemctl --user is-active --quiet quickshell; then
            echo -e "${GREEN}Quickshell is running successfully.${NC}"

            if journalctl --user -u quickshell -n 20 --no-pager 2>/dev/null | grep -qi "qml.*error\|module.*not installed"; then
                echo -e "${YELLOW}Warning: QML errors detected in logs.${NC}"
                echo "Run: journalctl --user -u quickshell -n 50"
            fi
        else
            echo -e "${RED}Quickshell failed to start.${NC}"
            echo "Check logs: journalctl --user -u quickshell -n 50"
            echo "Try manual start: quickshell -c ~/.config/quickshell/chima"
        fi
    else
        echo -e "${RED}Quickshell rebuild failed!${NC}"
        echo "Try manual rebuild: yay -S quickshell-git --rebuild"
    fi
fi

if [ "$GRUB_UPDATED" = true ]; then
    echo "Updating GRUB configuration..."

    if [ -f ~/.config/grub/grub_customize.sh ]; then
        echo "  → Running GRUB customization script..."
        bash ~/.config/grub/grub_customize.sh
        echo -e "${GREEN}GRUB customization was successfull.${NC}"
    else
        sudo grub-mkconfig -o /boot/grub/grub.cfg
        echo -e "${GREEN}GRUB configuration updated.${NC}"
        echo -e "${YELLOW}  Tip: Create ~/.config/grub/grub_customize.sh for custom GRUB settings.${NC}"
    fi
fi

echo "Clearing old package cache..."
sudo pacman -Sc --noconfirm
yay -Sc --noconfirm
echo -e "${GREEN}Package cache cleared.${NC}"

echo "Updating desktop database..."
update-desktop-database ~/.local/share/applications 2>/dev/null || true
echo -e "${GREEN}Desktop database updated.${NC}"



pacnew_files=$(find /etc -name "*.pacnew" 2>/dev/null || true)
if [ -n "$pacnew_files" ]; then
    echo -e "${YELLOW}Files .pacnew found:${NC}"
    echo "$pacnew_files"
    echo "Review and merge these files manually."
fi

if command -v nvim &> /dev/null; then
    echo "Updating NeoVim plugins..."
    nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
    echo -e "${GREEN}NeoVim plugins updated.${NC}"
fi

echo ""
echo "[7/7] Running system health check..."

failed_services=$(systemctl --failed --no-pager --no-legend 2>/dev/null || true)
if [ -n "$failed_services" ]; then
    echo -e "${RED}Failed system services:${NC}"
    echo "$failed_services"
else
    echo -e "${GREEN}No failed services.${NC}"
fi

disk_usage=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$disk_usage" -gt 90 ]; then
    echo -e "${RED}Disk usage is high: ${disk_usage}%${NC}"
else
    echo -e "${GREEN}Disk usage: ${disk_usage}%${NC}"
fi

echo ""
echo "Summary:"
if [ "$UPDATES_AVAILABLE" = true ]; then
    echo "  • System Packages: Updated"
    echo "  • AUR Packages: Updated"
else
    echo "  • System Packages: Already up to date"
    echo "  • AUR Packages: Already up to date"
fi
echo "  • Flatpak Apps: Updated"
echo "  • Maintenance Tasks: Completed"
[ "$QUICKSHELL_UPDATED" = true ] && echo "  • Quickshell: Recompiled."
[ "$GRUB_UPDATED" = true ] && echo "  • GRUB: Configuration Regenerated."
echo ""
echo "Tip: Run this script weekly to keep your system up to date."
echo ""

if [ "$KERNEL_UPDATED" = true ]; then
    echo -e "${YELLOW}Kernel was updated - Reboot required.${NC}"
    echo ""
    read -p "Reboot now? (y/N) " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo reboot
    else
        echo "Remember to reboot soon to use the new kernel."
    fi
fi