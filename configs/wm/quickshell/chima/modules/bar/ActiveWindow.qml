import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

Item {
    id: root
    property var screen: root.QsWindow.window?.screen
    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(screen)
    readonly property Toplevel activeWindow: ToplevelManager.activeToplevel

    property string activeWindowAddress: `0x${activeWindow?.HyprlandToplevel?.address}`
    property bool focusingThisMonitor: HyprlandData.activeWorkspace?.monitor == monitor.name
    property var biggestWindow: HyprlandData.biggestWindowForWorkspace(HyprlandData.monitors[root.monitor?.id]?.activeWorkspace.id)

    // Dynamic character limit based on screen width
    readonly property int maxTitleChars: {
        const width = screen?.width ?? 1920;
        if (width >= 2560) return 50;   // 2K/4K screens
        if (width >= 1920) return 40;   // 1080p screens
        if (width >= 1600) return 30;   // Medium screens
        if (width >= 1200) return 20;   // Smaller screens
        return 10;                       // Very small screens
    }

    implicitWidth: colLayout.implicitWidth

    ColumnLayout {
        id: colLayout

        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 2
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: -4

        StyledText {
            Layout.fillWidth: true
            font.pixelSize: Appearance.font.pixelSize.smaller
            color: Appearance.colors.colSubtext
            elide: Text.ElideRight
            text: root.focusingThisMonitor && root.activeWindow?.activated && root.biggestWindow ? 
                root.activeWindow?.appId :
                (root.biggestWindow?.class) ?? Translation.tr("Desktop")

        }

        StyledText {
            Layout.fillWidth: true
            font.pixelSize: Appearance.font.pixelSize.small
            color: Appearance.colors.colOnLayer0
            elide: Text.ElideRight
            text: {
                let fullText = root.focusingThisMonitor && root.activeWindow?.activated && root.biggestWindow ?
                    root.activeWindow?.title :
                    (root.biggestWindow?.title) ?? `${Translation.tr("Workspace")} ${monitor.activeWorkspace?.id}`;
                return fullText && fullText.length > root.maxTitleChars ? fullText.substring(0, root.maxTitleChars) + "..." : fullText;
            }
        }

    }

}
