pragma ComponentBehavior: Bound

import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions as CF
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

Scope {
    id: root

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bgRoot

            required property var modelData
            // Workspaces
            property HyprlandMonitor monitor: Hyprland.monitorFor(modelData)
            property list<var> relevantWindows: HyprlandData.windowList.filter(win => win.monitor == monitor.id && win.workspace.id >= 0).sort((a, b) => a.workspace.id - b.workspace.id)
            property int firstWorkspaceId: relevantWindows[0]?.workspace.id || 1
            property int lastWorkspaceId: relevantWindows[relevantWindows.length - 1]?.workspace.id || 10
            // Wallpaper
            property string wallpaperPath: Config.options.background.wallpaperPath
            property bool wallpaperIsVideo: Config.options.background.wallpaperPath.endsWith(".mp4")
                || Config.options.background.wallpaperPath.endsWith(".webm")
                || Config.options.background.wallpaperPath.endsWith(".mkv")
                || Config.options.background.wallpaperPath.endsWith(".avi")
                || Config.options.background.wallpaperPath.endsWith(".mov")            
            property real preferredWallpaperScale: Config.options.background.parallax.workspaceZoom
            property real effectiveWallpaperScale: 1 // Some reasonable init value, to be updated
            property int wallpaperWidth: modelData.width // Some reasonable init value, to be updated
            property int wallpaperHeight: modelData.height // Some reasonable init value, to be updated

            // Layer props
            screen: modelData
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: GlobalStates.screenLocked ? WlrLayer.Top : WlrLayer.Bottom
            // WlrLayershell.layer: WlrLayer.Bottom
            WlrLayershell.namespace: "quickshell:background"
            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            color: "transparent"

            onWallpaperPathChanged: {
                bgRoot.updateZoomScale()
            }

            // Wallpaper zoom scale
            function updateZoomScale() {
                getWallpaperSizeProc.path = bgRoot.wallpaperPath
                getWallpaperSizeProc.running = true;
            }
            Process {
                id: getWallpaperSizeProc
                property string path: bgRoot.wallpaperPath
                command: [ "magick", "identify", "-format", "%w %h", path ]
                stdout: StdioCollector {
                    id: wallpaperSizeOutputCollector
                    onStreamFinished: {
                        const output = wallpaperSizeOutputCollector.text.trim()
                        if (output) {
                            const [width, height] = output.split(" ").map(Number);
                            if (!isNaN(width) && !isNaN(height)) {
                                bgRoot.wallpaperWidth = width
                                bgRoot.wallpaperHeight = height
                                bgRoot.effectiveWallpaperScale = Math.max(1, Math.min(
                                    bgRoot.preferredWallpaperScale,
                                    width / bgRoot.screen.width,
                                    height / bgRoot.screen.height
                                ));
                            }
                        }
                    }
                }
            }

            // Wallpaper
            Image {
                visible: !bgRoot.wallpaperIsVideo && bgRoot.wallpaperPath != ""
                cache: false
                asynchronous: false
                property real value // 0 to 1, for offset
                value: {
                    // Range = half-groups that workspaces span on
                    const chunkSize = 5;
                    const lower = Math.floor(bgRoot.firstWorkspaceId / chunkSize) * chunkSize;
                    const upper = Math.ceil(bgRoot.lastWorkspaceId / chunkSize) * chunkSize;
                    const range = upper - lower;
                    return (Config.options.background.parallax.enableWorkspace ? ((bgRoot.monitor.activeWorkspace.id - lower) / range) : 0.5)
                        + (0.15 * GlobalStates.sidebarRightOpen * Config.options.background.parallax.enableSidebar)
                }
                property real effectiveValue: Math.max(0, Math.min(1, value))
                anchors.fill: parent
                source: bgRoot.wallpaperPath != "" ? bgRoot.wallpaperPath : ""
                fillMode: Image.PreserveAspectCrop
                Behavior on x {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }
                sourceSize {
                    width: bgRoot.screen.width * bgRoot.effectiveWallpaperScale
                    height: bgRoot.screen.height * bgRoot.effectiveWallpaperScale
                }

            }

            // Password prompt
            StyledText {
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: parent.bottom
                    bottomMargin: 30
                }
                opacity: (GlobalStates.screenLocked && !GlobalStates.screenLockContainsCharacters) ? 1 : 0
                scale: opacity
                visible: opacity > 0
                Behavior on opacity {
                    animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                }
                text: "Enter Password"
                color: CF.ColorUtils.transparentize(Appearance.colors.colOnSurface, 0.3)
                font {
                    pixelSize: Appearance.font.pixelSize.normal
                }
            }
        }
    }
}
