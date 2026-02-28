# QuickShell Upstream Sync Plan

This document tracks the plan for syncing END-4 upstream QuickShell features into Chima.
Based on analysis completed Feb 28, 2026.

## Key Decisions

| Decision | Choice |
|----------|--------|
| Translation.tr() calls | Add stub Translation service (returns key as-is) |
| Focus grab architecture | Adopt GlobalFocusGrab centralized service |
| Module loading | Flat LazyLoaders in shell.qml (Chima pattern) |
| Panel families | NOT adopted — modules loaded directly |
| Welcome screen | Keep Chima's current welcome |
| Default wallpaper | Not bundled |
| i18n/translations | Not added (stub only) |

## Naming Convention

All END-4 paths use `illogical-impulse` / `ii` prefix. Chima renames to `chima` throughout.

- END-4: `dots/.config/quickshell/ii/` → Chima: `configs/wm/quickshell/chima/`
- END-4: `modules/ii/` → Chima: `modules/` (flat, no `ii/` prefix)
- END-4: `qs.modules.ii.overlay` → Chima: `qs.modules.overlay`
- Config path: `~/.config/illogical-impulse/` → `~/.config/chima/`

---

## Phase 1: Foundation (Services, Models, Utils, Widgets, Assets)

These are shared dependencies required by all later phases. Must be done first.

### 1.1 New Services to Add

Add to `configs/wm/quickshell/chima/services/`:

| File | Source | Lines | Deps | Notes |
|------|--------|-------|------|-------|
| `BluetoothStatus.qml` | END-4 `services/BluetoothStatus.qml` | ~35 | `Quickshell.Bluetooth` | Replace Chima's polling `Bluetooth.qml` with this proper API-based service. Keep the name `BluetoothStatus` to match upstream |
| `EasyEffects.qml` | END-4 `services/EasyEffects.qml` | ~55 | `Quickshell.Services.Pipewire`, Config | Toggle EasyEffects, detect availability |
| `Idle.qml` | END-4 `services/Idle.qml` | ~45 | `Quickshell.Wayland.IdleInhibitor`, Persistent | Idle inhibitor toggle with persistent state |
| `Privacy.qml` | END-4 `services/Privacy.qml` | ~12 | `Quickshell.Services.Pipewire` | Detect active screen share / mic usage |
| `SongRec.qml` | END-4 `services/SongRec.qml` | ~85 | Config, Directories, scripts | Music recognition via SongRec CLI |
| `TaskbarApps.qml` | END-4 `services/TaskbarApps.qml` | ~60 | `Quickshell.Wayland.ToplevelManager`, Config | Dock/taskbar window tracking |
| `Updates.qml` | END-4 `services/Updates.qml` | ~45 | Config | Arch update checker via `checkupdates` |
| `TimerService.qml` | END-4 `services/TimerService.qml` | ~130 | Config, Persistent, Audio | Pomodoro + stopwatch |
| `LauncherApps.qml` | END-4 `services/LauncherApps.qml` | ~40 | Config | Launcher pinned app management |
| `LauncherSearch.qml` | END-4 `services/LauncherSearch.qml` | ~280 | AppSearch, Cliphist, Emojis, Config, models | Full search engine |
| `Wallpapers.qml` | END-4 `services/Wallpapers.qml` | ~180 | Directories, models, scripts | Wallpaper browsing/selection/thumbnails |
| `ConflictKiller.qml` | END-4 `services/ConflictKiller.qml` | ~40 | Config, FileUtils | Auto-kill conflicting processes |
| `SessionWarnings.qml` | END-4 `services/SessionWarnings.qml` | ~35 | Process | Detect running package managers |
| `GlobalFocusGrab.qml` | END-4 `services/GlobalFocusGrab.qml` | ~65 | `Quickshell.Hyprland` | Centralized focus grab |
| `PolkitService.qml` | END-4 `services/PolkitService.qml` | ~45 | `Quickshell.Services.Polkit` | PolicyKit auth agent |
| `TrayService.qml` | END-4 `services/TrayService.qml` | ~55 | `Quickshell.Services.SystemTray`, Config | System tray management |
| `Translation.qml` | **Create stub** | ~15 | None | Stub: `function tr(key, ...args) { return key }` |
| `ScreenshotAction.qml` | END-4 `modules/common/utils/ScreenshotAction.qml` | ~110 | Config, Directories, StringUtils | Screenshot action engine (this is in utils/ upstream but acts as a service) |
| `Images.qml` | **Check END-4** | TBD | TBD | If it exists as a service, add it |

**Total: ~19 new service files**

#### Services to Update (existing Chima files)

These already exist but need upstream changes applied:

| File | Key Changes |
|------|-------------|
| `Audio.qml` | Add back helper functions: `toggleMute()`, `incrementVolume()`, device listing, `playSystemSound()` — needed by TimerService and sidebar |
| `Battery.qml` | Add back `isFull`, health computation, sound effects, plug/unplug notifications |
| `Brightness.qml` | Add `getMonitorForScreen(screen)` function — needed by QuickSliders and NightLightDialog |
| `Cliphist.qml` | Consider adding Stash support, paste/superpaste/wipe, IPC handler back |
| `HyprlandData.qml` | Add Wayland toplevel helpers — needed by RegionSelector target regions |
| `Notifications.qml` | Add transient/unread tracking — needed by notification toggle |
| `ResourceUsage.qml` | Add history arrays (cpuUsageHistory, memoryUsageHistory, swapUsageHistory) — needed by Overlay resources widget. Fix hardcoded `enp8s0` |
| `MprisController.qml` | Add player dedup filtering back |
| `Network.qml` | Fix regex bug (missing backslash escape before `*`). Add `enableWifi()`, `rescanWifi()` functions |
| `HyprlandXkb.qml` | Add XKB variant matching back — important for ABNT2 keyboard |
| `AppSearch.qml` | Add dedup filter back |
| `MaterialThemeLoader.qml` | Add `resetFilePathNextTime` mechanism, `reapplyTheme()` function |
| `Hyprsunset.qml` | Add live color temp change listener — needed by NightLightDialog |
| `Bluetooth.qml` | **Replace entirely** with `BluetoothStatus.qml` (or rename and rewrite) |

#### qmldir Update

Update `configs/wm/quickshell/chima/services/qmldir` to register all new singletons.

### 1.2 New Common Models

Create `configs/wm/quickshell/chima/modules/common/models/`:

| File | Source | Lines | Notes |
|------|--------|-------|-------|
| `AdaptedMaterialScheme.qml` | END-4 | ~20 | Color scheme adapted to accent |
| `AnimatedTabIndexPair.qml` | END-4 | ~25 | Animated tab transition helper |
| `FolderListModelWithHistory.qml` | END-4 | ~55 | Folder navigation with back/forward |
| `IndexModel.qml` | END-4 | ~5 | Simple [0..count-1] model |
| `LauncherSearchResult.qml` | END-4 | ~35 | Search result data model |
| `QuickToggleModel.qml` | END-4 | ~15 | Base toggle model |
| `AntiFlashbangToggle.qml` | END-4 | — | Toggle model |
| `AudioToggle.qml` | END-4 | — | Toggle model |
| `BluetoothToggle.qml` | END-4 | — | Toggle model |
| `CloudflareWarpToggle.qml` | END-4 | — | Toggle model |
| `ColorPickerToggle.qml` | END-4 | — | Toggle model |
| `DarkModeToggle.qml` | END-4 | — | Toggle model |
| `EasyEffectsToggle.qml` | END-4 | — | Toggle model |
| `GameModeToggle.qml` | END-4 | — | Toggle model |
| `IdleInhibitorToggle.qml` | END-4 | — | Toggle model |
| `MicToggle.qml` | END-4 | — | Toggle model |
| `MusicRecognitionToggle.qml` | END-4 | — | Toggle model |
| `NetworkToggle.qml` | END-4 | — | Toggle model |
| `NightLightToggle.qml` | END-4 | — | Toggle model |
| `NotificationToggle.qml` | END-4 | — | Toggle model |
| `OnScreenKeyboardToggle.qml` | END-4 | — | Toggle model |
| `PowerProfilesToggle.qml` | END-4 | — | Toggle model |
| `ScreenSnipToggle.qml` | END-4 | — | Toggle model |
| `qmldir` | Create | — | Register all types |

**Total: ~24 files**

### 1.3 New Common Utils

Create `configs/wm/quickshell/chima/modules/common/utils/`:

| File | Source | Lines | Notes |
|------|--------|-------|-------|
| `ImageDownloaderProcess.qml` | END-4 | ~35 | Async image download via curl |
| `ScreenshotAction.qml` | END-4 | ~110 | Screenshot action engine (copy/edit/search/OCR/record). External deps: `magick`, `wl-copy`, `satty`/`swappy`, `tesseract`, `grim`, `wf-recorder` |
| `TempScreenshotProcess.qml` | END-4 | ~15 | Per-screen screenshot via grim |
| `qmldir` | Create | — | Register types |

**Total: 4 files**

### 1.4 New Common WidgetCanvas

Create `configs/wm/quickshell/chima/modules/common/widgets/widgetCanvas/`:

| File | Source | Lines | Notes |
|------|--------|-------|-------|
| `AbstractWidget.qml` | END-4 | ~30 | Draggable MouseArea base |
| `AbstractOverlayWidget.qml` | END-4 | ~12 | Extends AbstractWidget + pinned/clickthrough |
| `WidgetCanvas.qml` | END-4 | ~5 | Empty MouseArea container |
| `qmldir` | Create | — | Register types |

**Total: 4 files**

### 1.5 New/Updated Common Widgets

Check which of these widgets are missing from Chima's existing 61-file widget library:

| Widget | Needed By | Status |
|--------|-----------|--------|
| `WindowDialog` | All sidebar dialogs, Polkit | **Check if exists** |
| `WindowDialogTitle` | Dialogs | **Check if exists** |
| `WindowDialogParagraph` | Polkit | **Check if exists** |
| `WindowDialogButtonRow` | Dialogs | **Check if exists** |
| `WindowDialogSlider` | NightLight dialog | **Check if exists** |
| `WindowDialogSectionHeader` | NightLight dialog | **Check if exists** |
| `WindowDialogSeparator` | Dialogs | **Check if exists** |
| `DialogButton` | Dialogs | **Check if exists** |
| `AddressBar` | WallpaperSelector | **Check if exists** |
| `ThumbnailImage` | WallpaperSelector | **Check if exists** |
| `DirectoryIcon` | WallpaperSelector | **Check if exists** |
| `DashedBorder` | Overlay | **Check if exists** |
| `FadeLoader` | Overlay | **Check if exists** |
| `FloatingActionButton` | Settings, Sidebar | **Check if exists** |
| `Graph` | Overlay resources | **Check if exists** |
| `PagePlaceholder` | Volume dialog | **Check if exists** |
| `PopupWindow` | Tray menu | **Check if exists** |
| `PopupToolTip` | Tray items | **Check if exists** |
| `StyledPopup` | Tray overflow | **Check if exists** |
| `StyledComboBox` | Volume dialog | **Check if exists** |
| `FullscreenPolkitWindow` | Polkit | **Check if exists** |
| `Toolbar` / `IconToolbarButton` / `ToolbarTextField` | Overlay | **Check if exists** |
| `StyledScrollBar` | Lists | **Check if exists** |
| `StyledIndeterminateProgressBar` | Dialogs | **Check if exists** |
| `ScriptModel` | Multiple | **Check if exists** (may be a Quickshell built-in) |

**Action:** Run `ls` on Chima's widgets directory and diff against END-4's widgets directory to find missing files. Add any that are needed.

### 1.6 Common Module Updates

Update existing common modules:

| File | Changes Needed |
|------|---------------|
| `Appearance.qml` | Add Layer 4 / tertiary / error colors back, add `solveOverlayColor()`, add `variableAxes` |
| `Config.qml` | Add missing config sections: `tray.*`, `sidebar.quickSliders.*`, `sidebar.quickToggles.*`, `sidebar.keepRightSidebarLoaded`, `conflictKiller.*`, `musicRecognition.*`, `updates.*`, `time.pomodoro.*`, `overlay.*`, `crosshair.*`, `regionSelector.*`, `wallpaperSelector.*`, `policies.*`, `screenSnip.*`, `light.night.*`, `light.antiFlashbang.*`, `search.imageSearch.*`, `screenRecord.*` |
| `Persistent.qml` | Add missing sections: `overlay.*`, `timer.*`, `idle.*`, `sidebar.quickToggles.*` |
| `Directories.qml` | Add missing paths: `screenshotTemp`, `recordScriptPath`, `scriptPath`, additional XDG paths |
| `ColorUtils.qml` | Add back `solveOverlayColor()`, `applyAlpha()`, `isDark()`, `clamp01()` |
| `StringUtils.qml` | Add back `cleanCliphistEntry()`, `stringListContainsSubstring()`, `cleanPrefix()`, `cleanOnePrefix()`, `toTitleCase()`, `shellSingleQuoteEscape()` |
| `FileUtils.qml` | Add back `folderNameForPath()`, `parentDirectory()` |

### 1.7 Assets

#### Fluent Icons (232 SVGs)

Create `configs/wm/quickshell/chima/assets/icons/fluent/` and copy all 232 SVG files from END-4.

These are used throughout the UI for battery states, bluetooth, wifi, media, navigation icons.

#### Missing Top-level Icons (7 SVGs)

Add to `configs/wm/quickshell/chima/assets/icons/`:
- `gentoo-symbolic.svg` (distro icon)
- Others are AI-related (skip: `ai-openai-symbolic.svg`, `deepseek-symbolic.svg`, `google-gemini-symbolic.svg`, `ollama-symbolic.svg`, `openai-symbolic.svg`, `openrouter-symbolic.svg`)

#### Sound Effects

Sounds use system sound themes via `Audio.playSystemSound("alarm-clock-elapsed")` — no bundled files needed. The `playSystemSound()` function needs to be added back to `Audio.qml` (see Phase 1.1).

### 1.8 GlobalStates.qml Updates

Add missing state properties:

```qml
property bool overlayOpen: false
property bool wallpaperSelectorOpen: false
property bool regionSelectorOpen: false
property bool sessionOpen: false
property bool superDown: false  // needed by bar auto-hide
```

---

## Phase 2: New Modules

### 2.1 Overlay System

Create `configs/wm/quickshell/chima/modules/overlay/`:

| File | Source | Notes |
|------|--------|-------|
| `Overlay.qml` | END-4 `modules/ii/overlay/` | Entry point — PanelWindow with layer shell. Change `GlobalFocusGrab` references, rename imports from `qs.modules.ii.overlay` → `qs.modules.overlay` |
| `OverlayBackground.qml` | END-4 | Simple background rect |
| `OverlayContent.qml` | END-4 | Hosts widget canvas + taskbar |
| `OverlayContext.qml` | END-4 | Singleton: widget registry |
| `OverlayTaskbar.qml` | END-4 | Top toolbar |
| `OverlayWidgetDelegateChooser.qml` | END-4 | Maps widget identifiers to components |
| `StyledOverlayWidget.qml` | END-4 | Base widget class |
| `crosshair/Crosshair.qml` | END-4 | Crosshair widget |
| `crosshair/CrosshairContent.qml` | END-4 | Crosshair rendering |
| `floatingImage/FloatingImage.qml` | END-4 | Floating image widget |
| `fpsLimiter/FpsLimiter.qml` | END-4 | FPS limiter |
| `fpsLimiter/FpsLimiterContent.qml` | END-4 | FPS limiter UI |
| `notes/Notes.qml` | END-4 | Notes widget |
| `notes/NotesContent.qml` | END-4 | Notes editor |
| `recorder/Recorder.qml` | END-4 | Screenshot/record buttons |
| `resources/Resources.qml` | END-4 | CPU/RAM/swap graphs |
| `volumeMixer/VolumeMixer.qml` | END-4 | Volume mixer (cross-references sidebarRight VolumeDialogContent) |
| `qmldir` | Create | Register types |

**Total: 18 files**

**Import path changes needed:**
- `qs.modules.ii.overlay` → `qs.modules.overlay`
- `qs.modules.ii.sidebarRight.volumeMixer` → `qs.modules.sidebarRight.volumeMixer`
- All `Translation.tr(...)` calls will work via stub service

**Dependencies:** WidgetCanvas (Phase 1.4), utils (Phase 1.3), updated services (Phase 1.1), Persistent overlay states (Phase 1.6)

### 2.2 Wallpaper Selector

Create `configs/wm/quickshell/chima/modules/wallpaperSelector/`:

| File | Source | Notes |
|------|--------|-------|
| `WallpaperSelector.qml` | END-4 `modules/ii/wallpaperSelector/` | Entry point. Uses `GlobalFocusGrab`. Rename `GlobalStates.wallpaperSelectorOpen` |
| `WallpaperSelectorContent.qml` | END-4 | Full UI: grid, sidebar, toolbar |
| `WallpaperDirectoryItem.qml` | END-4 | Individual wallpaper/directory tile |
| `qmldir` | Create | Register types |

**Total: 4 files**

**Dependencies:** Wallpapers service (Phase 1.1), GlobalFocusGrab (Phase 1.1), FolderListModelWithHistory model (Phase 1.2), Images service, ThumbnailImage/AddressBar widgets (Phase 1.5)

### 2.3 Region Selector

Create `configs/wm/quickshell/chima/modules/regionSelector/`:

| File | Source | Notes |
|------|--------|-------|
| `RegionSelector.qml` | END-4 `modules/ii/regionSelector/` | Entry point: IPC + shortcuts. Rename `GlobalStates.regionSelectorOpen` |
| `RegionSelection.qml` | END-4 | Per-screen PanelWindow, main selection logic |
| `RegionFunctions.qml` | END-4 | Singleton: IoU, region filtering |
| `OptionsToolbar.qml` | END-4 | Selection mode switcher |
| `TargetRegion.qml` | END-4 | Visual target region overlay |
| `CursorGuide.qml` | END-4 | Cursor hint badge |
| `CircleSelectionDetails.qml` | END-4 | Circle selection rendering |
| `RectCornersSelectionDetails.qml` | END-4 | Rectangle selection rendering |
| `qmldir` | Create | Register types |

**Total: 9 files**

**Dependencies:** ScreenshotAction util (Phase 1.3), TempScreenshotProcess (Phase 1.3), HyprlandData updates (Phase 1.1), Config regionSelector section (Phase 1.6)

### 2.4 Polkit Agent

Create `configs/wm/quickshell/chima/modules/polkit/`:

| File | Source | Notes |
|------|--------|-------|
| `Polkit.qml` | END-4 `modules/ii/polkit/` | Entry point: FullscreenPolkitWindow |
| `PolkitContent.qml` | END-4 | Auth dialog UI |
| `qmldir` | Create | Register types |

**Total: 3 files**

**Dependencies:** PolkitService (Phase 1.1), FullscreenPolkitWindow widget (Phase 1.5)

### 2.5 Kill Dialog

Add `configs/wm/quickshell/chima/killDialog.qml`:

| File | Source | Notes |
|------|--------|-------|
| `killDialog.qml` | END-4 `killDialog.qml` | Standalone ApplicationWindow. Rename config refs |

**Total: 1 file**

**Dependencies:** ConflictKiller service (Phase 1.1), MaterialThemeLoader.reapplyTheme() (Phase 1.1)

### 2.6 shell.qml Updates

Add new `LazyLoader` entries for each new module:

```qml
// Existing modules...

// New modules
LazyLoader { active: enableOverlay; component: Overlay {} }
LazyLoader { active: enableWallpaperSelector; component: WallpaperSelector {} }
LazyLoader { active: enableRegionSelector; component: RegionSelector {} }
LazyLoader { active: enablePolkit; component: Polkit {} }
```

Add corresponding enable flags and imports.

---

## Phase 3: Sidebar Right Upgrades

### 3.1 Restructure SidebarRight

**Current Chima `SidebarRight.qml`** is a single 250-line file with everything inlined.

**Target:** Split into `SidebarRight.qml` (window shell) + `SidebarRightContent.qml` (content + dialog overlay system), matching END-4 architecture.

Changes to `SidebarRight.qml`:
- Switch from per-component `HyprlandFocusGrab` to `GlobalFocusGrab.addDismissable()`/`removeDismissable()`
- Move content to `SidebarRightContent.qml` loaded via `Loader`
- Add `Config.options.sidebar.keepRightSidebarLoaded` support

Create `SidebarRightContent.qml`:
- Import all new dialog modules
- Implement `ToggleDialog` pattern for Bluetooth, WiFi, NightLight, Audio Output, Audio Input dialogs
- Add `SystemButtonRow` with edit mode toggle (for android toggles)
- Add `QuickSliders` loader
- Add `LoaderedQuickPanelImplementation` for classic/android toggle style switching
- Wire dialog signals from toggle panels

### 3.2 Add QuickSliders

Create `configs/wm/quickshell/chima/modules/sidebarRight/QuickSliders.qml`:
- Brightness, Volume, Mic sliders
- Conditionally active based on `Config.options.sidebar.quickSliders.*`
- Uses `Brightness.getMonitorForScreen(screen)` and `Audio` service

### 3.3 Add Dialog Modules

Create new subdirectories under `configs/wm/quickshell/chima/modules/sidebarRight/`:

#### Bluetooth Dialog
| File | Source |
|------|--------|
| `bluetoothDevices/BluetoothDialog.qml` | END-4 |
| `bluetoothDevices/BluetoothDeviceItem.qml` | END-4 |

#### WiFi Dialog
| File | Source |
|------|--------|
| `wifiNetworks/WifiDialog.qml` | END-4 |
| `wifiNetworks/WifiNetworkItem.qml` | END-4 |

#### Night Light Dialog
| File | Source |
|------|--------|
| `nightLight/NightLightDialog.qml` | END-4 |

#### Volume Dialogs
| File | Source |
|------|--------|
| `volumeMixer/VolumeDialog.qml` | END-4 |
| `volumeMixer/VolumeDialogContent.qml` | END-4 |

Update existing volume mixer files if needed.

### 3.4 Add Pomodoro/Timer Tab

Create `configs/wm/quickshell/chima/modules/sidebarRight/pomodoro/`:

| File | Source |
|------|--------|
| `PomodoroWidget.qml` | END-4 |
| `PomodoroTimer.qml` | END-4 |
| `Stopwatch.qml` | END-4 |

Update `BottomWidgetGroup.qml` to add Timer as 3rd tab.

### 3.5 Add Android-Style Toggle Panel

Create `configs/wm/quickshell/chima/modules/sidebarRight/quickToggles/`:

| File | Source |
|------|--------|
| `AbstractQuickPanel.qml` | END-4 |
| `AndroidQuickPanel.qml` | END-4 |
| `ClassicQuickPanel.qml` | END-4 (refactor existing toggles into this) |
| `androidStyle/AndroidQuickToggleButton.qml` | END-4 |
| `androidStyle/AndroidToggleDelegateChooser.qml` | END-4 |
| `androidStyle/AndroidAntiFlashbangToggle.qml` | END-4 |
| `androidStyle/AndroidAudioToggle.qml` | END-4 |
| `androidStyle/AndroidBluetoothToggle.qml` | END-4 |
| `androidStyle/AndroidCloudflareWarpToggle.qml` | END-4 |
| `androidStyle/AndroidColorPickerToggle.qml` | END-4 |
| `androidStyle/AndroidDarkModeToggle.qml` | END-4 |
| `androidStyle/AndroidEasyEffectsToggle.qml` | END-4 |
| `androidStyle/AndroidGameModeToggle.qml` | END-4 |
| `androidStyle/AndroidIdleInhibitorToggle.qml` | END-4 |
| `androidStyle/AndroidMicToggle.qml` | END-4 |
| `androidStyle/AndroidMusicRecognition.qml` | END-4 |
| `androidStyle/AndroidNetworkToggle.qml` | END-4 |
| `androidStyle/AndroidNightLightToggle.qml` | END-4 |
| `androidStyle/AndroidNotificationToggle.qml` | END-4 |
| `androidStyle/AndroidOnScreenKeyboardToggle.qml` | END-4 |
| `androidStyle/AndroidPowerProfileToggle.qml` | END-4 |
| `androidStyle/AndroidScreenSnipToggle.qml` | END-4 |

Also update existing classic toggles:
- `BluetoothToggle.qml` → Use `BluetoothStatus` service instead of `Bluetooth`, add `altAction` for dialog
- `NetworkToggle.qml` → Add `altAction` for WiFi dialog
- `NightLight.qml` → Switch from `gammastep` to `Hyprsunset` to match upstream

### 3.6 Update CenterWidgetGroup

Change from 2-tab (Notifications + VolumeMixer) to notifications-only (full height), matching END-4. Volume mixing moves to the dialog overlay system.

### 3.7 Update Notification System

- Update `notifications/NotificationList.qml` and `notifications/NotificationStatusButton.qml` if needed
- Add unread/transient tracking support (from Notifications service update)

### 3.8 qmldir Updates

Update all `qmldir` files in sidebarRight subdirectories to register new types.

---

## Phase 4: Bar Upgrades

### 4.1 System Tray

Add to `configs/wm/quickshell/chima/modules/bar/`:

| File | Source | Notes |
|------|--------|-------|
| `SysTray.qml` | **Already exists** in Chima | Update to use `TrayService` instead of raw `SystemTray`, add `HyprlandFocusGrab` management |
| `SysTrayItem.qml` | **Already exists** in Chima | Update for monochrome icon support, tooltip |
| `SysTrayMenu.qml` | END-4 | New — nested menu system with `StackView` for submenus |
| `SysTrayMenuEntry.qml` | END-4 | New — individual menu entry with checkbox/radio support |

Check existing Chima `SysTray.qml` / `SysTrayItem.qml` against END-4 and update as needed.

### 4.2 Auto-Hide Bar

Update `configs/wm/quickshell/chima/modules/bar/Bar.qml`:

- Add `Config.options.bar.autoHide.*` support
- Add hover region with `MouseArea` for reveal-on-hover
- Add Super key show feature (requires `GlobalStates.superDown`)
- Add animation for sliding bar off-screen
- Add `exclusiveZone` toggling based on autoHide + pushWindows config
- Add `GlobalFocusGrab.addPersistent(barRoot)` call

### 4.3 Bar Config Sections

Ensure `Config.qml` has all bar-related config:
- `bar.autoHide.enable`, `bar.autoHide.pushWindows`, `bar.autoHide.showWhenPressingSuper.enable/.delay`, `bar.autoHide.hoverRegionWidth`

### 4.4 Bar Integration with Sidebar

Ensure BarContent properly integrates sidebar toggle:
- Right-click area toggles `GlobalStates.sidebarRightOpen`
- Sidebar button shows toggled state

---

## Phase 5: Lock Screen Upgrades

### 5.1 Fingerprint Auth

Update `configs/wm/quickshell/chima/modules/lock/`:

- Add fprintd integration to lock screen
- Check if END-4 ships `pam/` config for fingerprint → Chima already has `pam/` directory
- Update lock screen UI to show fingerprint icon/status
- Handle fprintd not being installed gracefully

### 5.2 Power Actions from Lock Screen

Update lock screen to add power buttons:
- Shutdown
- Reboot
- Suspend

These should be accessible from the lock screen UI.

---

## Phase 6: Scripts

### 6.1 Recording Script

Create `configs/wm/quickshell/chima/scripts/videos/record.sh`:
- Copy from END-4
- Change config path from `~/.config/illogical-impulse/config.json` → `~/.config/chima/config.json`
- Ensure `chmod +x`

### 6.2 Keyring Scripts

Create `configs/wm/quickshell/chima/scripts/keyring/`:

| File | Source | Notes |
|------|--------|-------|
| `is_unlocked.sh` | END-4 | Check keyring unlock status |
| `try_lookup.sh` | END-4 | Secret lookup |
| `unlock.sh` | END-4 | Keyring unlock prompt |

### 6.3 Music Recognition Script

Create `configs/wm/quickshell/chima/scripts/musicRecognition/`:

| File | Source | Notes |
|------|--------|-------|
| `recognize-music.sh` | END-4 | Audio record + SongRec recognition |

### 6.4 Thumbnail Scripts

Create `configs/wm/quickshell/chima/scripts/thumbnails/`:

| File | Source | Notes |
|------|--------|-------|
| `generate-thumbnails-magick.sh` | END-4 | ImageMagick fallback |
| `thumbgen.py` | END-4 | GNOME Desktop thumbnail generator. **Remove venv wrapper** — use system Python per Chima convention |

Note: Skip `thumbgen-venv.sh` — Chima doesn't use Python venvs.

### 6.5 Script Permissions

All `.sh` files must be `chmod 755`.

---

## Phase 7: Cleanup & Testing

### 7.1 Import Path Audit

Search all new/modified files for:
- `qs.modules.ii.` → Change to `qs.modules.`
- `illogical-impulse` / `illogical_impulse` → Change to `chima`
- `ii` references in import paths
- Verify all `qmldir` files are correct

### 7.2 Config.qml Audit

Ensure all config sections referenced by new code exist in `Config.qml`.

### 7.3 Persistent.qml Audit

Ensure all persistent state sections referenced by new code exist in `Persistent.qml`.

### 7.4 GlobalStates.qml Audit

Ensure all global state properties referenced by new code exist.

### 7.5 Package Dependencies

Add new system packages to `lib/packages.sh`:
- `songrec` — music recognition (AUR)
- `tesseract` / `tesseract-data-eng` — OCR for region selector
- `satty` or `swappy` — screenshot annotation
- `qalc` — calculator for launcher search
- `pacman-contrib` — `checkupdates` for Updates service
- `fprintd` — fingerprint auth (optional)

### 7.6 Functional Testing

Test each phase after implementation:
1. QuickShell starts without errors
2. Sidebar right opens with new layout
3. Quick toggles work (classic + android styles)
4. Dialogs open/close properly (Bluetooth, WiFi, NightLight, Volume)
5. Overlay toggles and widgets work
6. Wallpaper selector opens and can change wallpapers
7. Region selector works for screenshots/recording
8. Polkit dialog appears when auth is needed
9. System tray shows icons and menus work
10. Bar auto-hide works
11. Lock screen fingerprint + power buttons work
12. Recording script works

---

## File Count Summary

| Phase | New Files | Modified Files | Total |
|-------|-----------|----------------|-------|
| 1. Foundation | ~290 (services, models, utils, widgetCanvas, fluent icons, widgets) | ~20 (service updates, common module updates, GlobalStates, qmldirs) | ~310 |
| 2. New Modules | ~35 (overlay, wallpaper, region, polkit, kill dialog) | ~1 (shell.qml) | ~36 |
| 3. Sidebar Right | ~30 (dialogs, android toggles, pomodoro, quick sliders) | ~8 (SidebarRight, CenterWidgetGroup, BottomWidgetGroup, classic toggles) | ~38 |
| 4. Bar | ~2 (tray menu files) | ~3 (Bar.qml, SysTray.qml, SysTrayItem.qml) | ~5 |
| 5. Lock Screen | ~0 | ~2-3 (lock module files) | ~3 |
| 6. Scripts | ~7 (record, keyring, music, thumbnails) | ~0 | ~7 |
| 7. Cleanup | ~0 | ~5-10 (import audits, qmldirs) | ~10 |
| **TOTAL** | **~364** | **~40** | **~409** |

---

## Dependency Order (Critical Path)

```
Phase 1.1 (services)
  ├── Phase 1.2 (models)        ─┐
  ├── Phase 1.3 (utils)          │
  ├── Phase 1.4 (widgetCanvas)   ├── Phase 2 (modules) ──┐
  ├── Phase 1.5 (widgets)        │                        │
  ├── Phase 1.6 (common updates) │                        ├── Phase 3 (sidebar) ─── Phase 4 (bar)
  ├── Phase 1.7 (assets)        ─┘                        │
  └── Phase 1.8 (GlobalStates)                            └── Phase 5 (lock)

Phase 6 (scripts) ─── can be done in parallel with Phases 2-5
Phase 7 (cleanup) ─── after everything else
```
