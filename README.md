# Chima

A complete Arch Linux + Hyprland + QuickShell distribution with automated installation and configuration management.

## Overview

**Chima** is a fully configured Arch Linux system featuring:

- **Hyprland** - Modern Wayland compositor with beautiful animations
- **QuickShell** - QML-based shell with custom widgets and services (181 QML files)
- **Complete Development Environment** - Docker, Git, VS Code, Neovim, and more
- **Custom SDDM Theme** - Matching the desktop aesthetic
- **Optimized Configuration** - GRUB, TLP, systemd services all pre-configured
- **One-Command Installation** - Transform a fresh Arch install into your perfect setup

## Quick Start

### Prerequisites

- Fresh Arch Linux installation (via `archinstall`)
- Active internet connection
- At least 20GB free disk space
- User account with sudo privileges

### Installation

```bash
# Clone the repository
git clone https://github.com/gabrielbvicari/chima.git
cd chima

# Run the installation
./setup
```

The setup script will guide you through:
1. Package installation (120+ packages)
2. System configuration (services, SDDM, GRUB)
3. Configuration restoration (dotfiles, themes)
4. Authentication setup (git, gcloud, github)

### What Gets Installed

**Window Manager & Shell:**
- Hyprland with custom keybinds and rules
- QuickShell with 181 QML files + 25 qmldir files
- Qt6 stack (qt6-base, qt6-declarative, qt6-wayland, etc.)

**Development Tools:**
- Docker + Docker Compose
- Git + GitHub CLI + Git Delta
- Neovim (LazyVim configuration)
- Visual Studio Code
- Python, Node.js, Rust toolchains
- Linters: ESLint, Pylint, Luacheck, Shellcheck, etc.

**Terminal & Shell:**
- Fish shell with custom configuration
- Starship prompt (main + minimal variants)
- Ghostty + Kitty terminal emulators
- Modern CLI tools: bat, fd, fzf, lsd, yazi, etc.

**GUI Applications:**
- Browsers: Vivaldi, Zen Browser
- Graphics: GIMP, Inkscape
- Productivity: Obsidian, Slack, Lens (Kubernetes IDE)
- Media: TIDAL HiFi, Discord
- File Manager: Dolphin
- System Tools: btop, nvtop, KDE System Settings

**Fonts & Themes:**
- JetBrains Mono Nerd Font
- Material Symbols Variable
- Gabarito, Rubik, Readex Pro
- GTK themes: Adwaita, Breeze Plus, Darkly
- Qt themes: Kvantum, qt5ct, qt6ct
- Icon theme: Bibata Modern Classic

**Optional (CLI tools requiring authentication):**
- Google Cloud CLI (gcloud, bq, gsutil, cloud-sql-proxy)
- pCloud Drive
- Claude Code CLI

## Repository Structure

```
chima/
├── setup                   # Main installation script
├── update_system.sh        # Update system and packages
├── lib/                    # Shared libraries
│   ├── colors.sh          # Color definitions and print functions
│   ├── functions.sh       # Shared functions
│   └── packages.sh        # All 120+ packages categorized
├── configs/               # All system configurations
│   ├── wm/               # QuickShell + Hyprland
│   ├── editors/          # Neovim + VS Code
│   ├── shell/            # Fish + Starship
│   ├── terminal/         # Ghostty + Kitty
│   ├── dev/              # Lazygit, Docker, linters
│   ├── apps/             # GUI app configurations
│   ├── theme/            # GTK, Qt, Matugen
│   ├── system/           # SDDM, GRUB, TLP, systemd
│   └── git/              # .gitconfig
└── wallpapers/            # Wallpapers
```

## Usage

### Main Commands

```bash
# Full installation (run once on fresh Arch)
./setup

# Update system and packages
./update_system.sh
```

### QuickShell Management

```bash
# Restart QuickShell
systemctl --user restart quickshell

# Check QuickShell status
systemctl --user status quickshell

# View QuickShell logs
journalctl --user -u quickshell -f
```

## Features

### Custom SDDM Theme

- Matching Hyprland/QuickShell aesthetic
- Profile picture integration
- Custom caps lock indicator
- Fallback login for no-user scenarios
- RedHatDisplay fonts

### QuickShell Configuration

- 181 QML files with complete UI
- 25 qmldir files for Qt6 compatibility
- Custom widgets: Clock, Weather, Resources, Todo
- Services: Notifications, App Search, MprisController, etc.
- Full Hyprland integration

### Hyprland Setup

- Custom keybinds and workspace rules
- Gap and border configurations
- Hypridle, Hyprlock, Hyprsunset integration
- Screenshot tools (Hyprshot, Slurp, Swappy)

### Development Environment

- Full Docker setup with user in docker group
- Git configured with delta diff viewer
- Neovim with LazyVim (70+ plugins)
- VS Code with extensions auto-installed
- Pre-commit hooks configured
- All linters and formatters ready

## Post-Installation

After running `./setup`, you'll need to:

1. **Reboot** - Required for group changes, SDDM theme, and kernel updates

2. **Verify QuickShell:**
   ```bash
   systemctl --user status quickshell
   ```

3. **Test Hyprland Keybinds:**
   - `Super + Enter` - Open terminal
   - `Super + Q` - Close window
   - `Super + Space` - Toggle floating
   - `Super + F` - Toggle fullscreen

## Updates

```bash
./update_system.sh
```

The update script:
- Checks for available updates before proceeding
- Backs up current configuration automatically
- Updates official packages (pacman)
- Updates AUR packages (yay) with retry logic for rate limits
- Updates Flatpak packages
- Detects and rebuilds QuickShell after Qt6 updates
- Regenerates GRUB if updated
- Updates Neovim plugins
- Shows health check summary

## Troubleshooting

### QuickShell Not Starting

```bash
# Check service status
systemctl --user status quickshell

# View logs
journalctl --user -u quickshell -f

# Rebuild QuickShell (after Qt6 update)
yay -S quickshell-git --rebuild
```

### SDDM Theme Not Applying

```bash
# Verify theme is installed
ls /usr/share/sddm/themes/chima

# Check SDDM config
cat /etc/sddm.conf.d/theme.conf
```

### Missing Packages

```bash
# Reinstall all packages
./setup
```

## Customization

All configurations are in the `configs/` directory and can be modified before running `./setup`.

## Credits

Originally based on [END-4's dots-hyprland](https://github.com/end-4/dots-hyprland). This project has since diverged into an independent configuration with its own installation system, update scripts, and structure. END-4's upstream is kept as a read-only reference remote for cherry-picking improvements.

## License

MIT License - Feel free to use and modify as needed.
