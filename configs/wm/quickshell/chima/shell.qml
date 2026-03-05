//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic
//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000

// Adjust this to make the shell smaller or larger
////@ pragma Env QT_SCALE_FACTOR=1

import "modules/common"
import "services"

import "modules/background"
import "modules/bar"
import "modules/cheatsheet"
import "modules/dock"
import "modules/lock"
import "modules/mediaControls"
import "modules/notificationPopup"
import "modules/onScreenDisplay"
import "modules/onScreenKeyboard"
import "modules/overlay"
import "modules/overview"
import "modules/polkit"
import "modules/regionSelector"
import "modules/screenCorners"
import "modules/session"
import "modules/sidebarRight"
import "modules/wallpaperSelector"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

ShellRoot {
    property bool enableBar: true
    property bool enableBackground: true
    property bool enableCheatsheet: true
    property bool enableDock: true
    property bool enableLock: true
    property bool enableMediaControls: true
    property bool enableNotificationPopup: true
    property bool enableOnScreenDisplayBrightness: true
    property bool enableOnScreenDisplayVolume: true
    property bool enableOnScreenKeyboard: true
    property bool enableOverlay: true
    property bool enableOverview: true
    property bool enablePolkit: true
    property bool enableRegionSelector: true
    property bool enableReloadPopup: true
    property bool enableScreenCorners: true
    property bool enableSession: true
    property bool enableSidebarRight: true
    property bool enableWallpaperSelector: true

    Component.onCompleted: {
        MaterialThemeLoader.reapplyTheme()
        Hyprsunset.load()
        FirstRunExperience.load()
        ConflictKiller.load()
        Cliphist.refresh()

        Quickshell.execDetached(["bash", "-c", `${Directories.wallpaperSwitchScriptPath} --noswitch`])

        const firstRunFilePath = FileUtils.trimFileProtocol(`${Directories.state}/user/first_run.txt`)
        if (!Quickshell.fileExists(firstRunFilePath)) {
            const welcomePath = Quickshell.shellPath("welcome.qml")
            Quickshell.execDetached(["qs", "-p", welcomePath])
        }
    }

    LazyLoader { active: enableBar; component: Bar {} }
    LazyLoader { active: enableBackground; component: Background {} }
    LazyLoader { active: enableCheatsheet; component: Cheatsheet {} }
    LazyLoader { active: enableDock && Config.options.dock.enable; component: Dock {} }
    LazyLoader { active: enableLock; component: Lock {} }
    LazyLoader { active: enableMediaControls; component: MediaControls {} }
    LazyLoader { active: enableNotificationPopup; component: NotificationPopup {} }
    LazyLoader { active: enableOnScreenDisplayBrightness; component: OnScreenDisplayBrightness {} }
    LazyLoader { active: enableOnScreenDisplayVolume; component: OnScreenDisplayVolume {} }
    LazyLoader { active: enableOnScreenKeyboard; component: OnScreenKeyboard {} }
    LazyLoader { active: enableOverlay; component: Overlay {} }
    LazyLoader { active: enableOverview; component: Overview {} }
    LazyLoader { active: enablePolkit; component: Polkit {} }
    LazyLoader { active: enableRegionSelector; component: RegionSelector {} }
    LazyLoader { active: enableReloadPopup; component: ReloadPopup {} }
    LazyLoader { active: enableScreenCorners; component: ScreenCorners {} }
    LazyLoader { active: enableSession; component: Session {} }
    LazyLoader { active: enableSidebarRight; component: SidebarRight {} }
    LazyLoader { active: enableWallpaperSelector; component: WallpaperSelector {} }

    IpcHandler {
        target: "welcome"

        function open(): void {
            const welcomePath = Quickshell.shellPath("welcome.qml")
            Quickshell.execDetached(["qs", "-p", welcomePath])
        }
    }

    GlobalShortcut {
        name: "welcomeOpen"
        description: "Opens welcome screen"

        onPressed: {
            const welcomePath = Quickshell.shellPath("welcome.qml")
            Quickshell.execDetached(["qs", "-p", welcomePath])
        }
    }
}

