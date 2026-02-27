#!/bin/bash
# Chima bootstrap installer.
# Usage: bash <(curl -s https://raw.githubusercontent.com/gabrielbvicari/chima/main/install.sh)

set -eo pipefail

REPO="https://github.com/gabrielbvicari/chima.git"
INSTALL_DIR="$HOME/chima"

if ! command -v git &>/dev/null; then
    echo "Installing git..."
    sudo pacman -S --noconfirm git
fi

if [ -d "$INSTALL_DIR" ]; then
    echo "Updating existing installation..."
    git -C "$INSTALL_DIR" pull
else
    echo "Cloning chima..."
    git clone "$REPO" "$INSTALL_DIR"
fi

cd "$INSTALL_DIR"
exec ./setup
