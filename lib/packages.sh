#!/bin/bash
# Package lists for Chima installation.

BASE_PACKAGES=(
    "base"
    "base-devel"
    "linux"
    "linux-firmware"
    "amd-ucode"
    "grub"
    "efibootmgr"
    "os-prober"
    "dosfstools"
    "mtools"
    "ntfs-3g"
)

NETWORK_PACKAGES=(
    "iwd"
    "wireless_tools"
    "network-manager-applet"
    "bluez"
    "bluez-utils"
)

DISPLAY_PACKAGES=(
    "xorg-server"
    "xorg-xinit"
    "xorg-xrandr"
    "xf86-video-amdgpu"
    "xf86-video-ati"
    "vulkan-radeon"
)

AUDIO_PACKAGES=(
    "pipewire"
    "pipewire-alsa"
    "pipewire-pulse"
    "gst-plugin-pipewire"
    "libpulse"
    "sof-firmware"
)

# Chima basic dependencies:
WM_BASIC_PACKAGES=(
    "axel"
    "bc"
    "coreutils"
    "cliphist"
    "cmake"
    "cpio"
    "curl"
    "rsync"
    "wget"
    "ripgrep"
    "jq"
    "meson"
    "xdg-user-dirs"
)

# Chima Hyprland dependencies:
WM_HYPRLAND_PACKAGES=(
    "hypridle"
    "hyprcursor"
    "hyprland"
    "hyprland-qt-support"
    "hyprlang"
    "hyprlock"
    "hyprpicker"
    "hyprsunset"
    "hyprutils"
    "hyprwayland-scanner"
    "xdg-desktop-portal-hyprland"
    "wl-clipboard"
)

# Chima audio dependencies:
WM_AUDIO_PACKAGES=(
    "cava"
    "pavucontrol-qt"
    "wireplumber"
    "libdbusmenu-gtk3"
    "playerctl"
)

# Chima backlight dependencies:
WM_BACKLIGHT_PACKAGES=(
    "geoclue"
    "brightnessctl"
    "ddcutil"
)

# Chima screencapture dependencies:
WM_SCREENCAPTURE_PACKAGES=(
    "hyprshot"
    "slurp"
    "swappy"
    "tesseract"
    "tesseract-data-eng"
    "wf-recorder"
)

# Chima toolkit dependencies:
WM_TOOLKIT_PACKAGES=(
    "kdialog"
    "qt6-5compat"
    "qt6-base"
    "qt6-declarative"
    "qt6-imageformats"
    "qt6-multimedia"
    "qt6-positioning"
    "qt6-quicktimeline"
    "qt6-sensors"
    "qt6-svg"
    "qt6-tools"
    "qt6-translations"
    "qt6-virtualkeyboard"
    "qt6-wayland"
    "syntax-highlighting"
    "upower"
    "wtype"
    "ydotool"
)

# Chima widgets dependencies:
WM_WIDGETS_PACKAGES=(
    "fuzzel"
    "glib2"
    "nm-connection-editor"
    "translate-shell"
)

# Chima portal dependencies:
WM_PORTAL_PACKAGES=(
    "xdg-desktop-portal"
    "xdg-desktop-portal-kde"
    "xdg-desktop-portal-gtk"
)

# Chima KDE dependencies:
WM_KDE_PACKAGES=(
    "bluedevil"
    "gnome-keyring"
    "networkmanager"
    "plasma-nm"
    "polkit-kde-agent"
    "dolphin"
    "systemsettings"
)

# Chima Python dependencies:
WM_PYTHON_PACKAGES=(
    "python-build"
    "python-numpy"
    "python-pillow"
    "python-pywayland"
    "python-setproctitle"
    "python-setuptools-scm"
    "python-wheel"
    "clang"
    "uv"
    "gtk4"
    "libadwaita"
    "libsoup3"
    "libportal-gtk4"
    "gobject-introspection"
    "sassc"
    "python-opencv"
)

FONT_PACKAGES=(
    "fontconfig"
    "ttf-jetbrains-mono-nerd"
)

THEME_PACKAGES=(
    "breeze"
)

SHELL_PACKAGES=(
    "eza"
    "fish"
    "starship"
    "bat"
    "fd"
    "fzf"
    "lsd"
    "tree"
    "yazi"
    "thefuck"
)

TERMINAL_PACKAGES=(
    "kitty"
)

EDITOR_PACKAGES=(
    "neovim"
    "vim"
    "nano"
    "less"
)

DEV_TOOLS_PACKAGES=(
    "git"
    "git-delta"
    "docker"
    "docker-compose"
    "nodejs"
    "npm"
    "python-pip"
    "python-debugpy"
    "python-black"
    "python-flake8"
    "python-pylint"
    "lua-language-server"
    "luacheck"
    "luarocks"
    "rust-analyzer"
    "pre-commit"
    "cppcheck"
    "mypy"
    "shellcheck"
    "stylua"
    "yamllint"
    "lazygit"
)

CLOUD_PACKAGES=()
# Note: google-cloud-cli and components are AUR packages.

UTILITY_PACKAGES=(
    "btop"
    "htop"
    "nvtop"
    "fastfetch"
    "flatpak"
    "tlp"
    "uwsm"
    "zram-generator"
    "dunst"
    "gammastep"
    "xdg-utils"
    "dmidecode"
    "smartmontools"
    "wofi"
    "dysk"
)

APP_PACKAGES=(
    "sddm"
    "gimp"
    "inkscape"
    "obsidian"
    "partitionmanager"
    "mpv"
    "caligula"
    "vivaldi"
    "plasma-browser-integration"
    "plasma-systemmonitor"
)

AUR_CRITICAL_PACKAGES=(
    "yay-bin"
    "quickshell-git"
    "sddm-silent-theme"
    "matugen-bin"
)

AUR_FONT_PACKAGES=(
    "otf-space-grotesk"
    "ttf-gabarito-git"
    "ttf-material-symbols-variable-git"
    "ttf-readex-pro"
    "ttf-rubik-vf"
    "ttf-twemoji"
    "redhat-fonts"
)

AUR_THEME_PACKAGES=(
    "adw-gtk-theme-git"
    "breeze-plus"
    "darkly-bin"
    "kde-material-you-colors"
    "python-materialyoucolor"
    "python-pywal16"
    "bibata-cursor-theme"
)

AUR_DEV_PACKAGES=(
    "visual-studio-code-bin"
    "beekeeper-studio-bin"
    "lazydocker"
)

AUR_APP_PACKAGES=(
    "slack-desktop"
    "tidal-hifi-bin"
    "localsend-bin"
    "lens-bin"
    "zen-browser-bin"
    "sioyek"
    "wlogout"
    "ghostty"
    "astroterm"
)

AUR_OPTIONAL_GCLOUD_PACKAGES=(
    "google-cloud-cli"
    "google-cloud-cli-bq"
    "google-cloud-cli-component-gke-gcloud-auth-plugin"
    "google-cloud-cli-gsutil"
    "cloud-sql-proxy"
)

AUR_OPTIONAL_PCLOUD_PACKAGES=(
    "pcloud-drive"
)

OPTIONAL_GITHUB_PACKAGES=(
    "github-cli"
)

AUR_SYSTEM_PACKAGES=(
    "qt6-avif-image-plugin"
)

FLATPAK_PACKAGES=(
    "com.discordapp.Discord"
)

NPM_PACKAGES=(
    "nativefier"
    "eslint"
    "prettier"
    "typescript"
    "ts-node"
)

NPM_OPTIONAL_CLAUDE_PACKAGES=(
    "@anthropics/claude-code"
)

# All official repo packages:
ALL_OFFICIAL_PACKAGES=(
    "${BASE_PACKAGES[@]}"
    "${NETWORK_PACKAGES[@]}"
    "${DISPLAY_PACKAGES[@]}"
    "${AUDIO_PACKAGES[@]}"
    "${WM_BASIC_PACKAGES[@]}"
    "${WM_HYPRLAND_PACKAGES[@]}"
    "${WM_AUDIO_PACKAGES[@]}"
    "${WM_BACKLIGHT_PACKAGES[@]}"
    "${WM_SCREENCAPTURE_PACKAGES[@]}"
    "${WM_TOOLKIT_PACKAGES[@]}"
    "${WM_WIDGETS_PACKAGES[@]}"
    "${WM_PORTAL_PACKAGES[@]}"
    "${WM_KDE_PACKAGES[@]}"
    "${WM_PYTHON_PACKAGES[@]}"
    "${FONT_PACKAGES[@]}"
    "${THEME_PACKAGES[@]}"
    "${SHELL_PACKAGES[@]}"
    "${TERMINAL_PACKAGES[@]}"
    "${EDITOR_PACKAGES[@]}"
    "${DEV_TOOLS_PACKAGES[@]}"
    "${UTILITY_PACKAGES[@]}"
    "${APP_PACKAGES[@]}"
)

# All AUR packages:
ALL_AUR_PACKAGES=(
    "${AUR_CRITICAL_PACKAGES[@]}"
    "${AUR_FONT_PACKAGES[@]}"
    "${AUR_THEME_PACKAGES[@]}"
    "${AUR_DEV_PACKAGES[@]}"
    "${AUR_APP_PACKAGES[@]}"
    "${AUR_SYSTEM_PACKAGES[@]}"
)
