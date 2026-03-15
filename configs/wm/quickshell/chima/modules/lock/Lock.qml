pragma ComponentBehavior: Bound
import qs
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.panels.lock
import QtQuick
import Quickshell
import Quickshell.Hyprland

LockScreen {
    id: root

    property var savedWorkspaces: ({})

    Timer {
        id: restoreTimer
        interval: 150
        repeat: false
        onTriggered: {
            var batch = ""
            for (var j = 0; j < Quickshell.screens.length; ++j) {
                var monName = Quickshell.screens[j].name
                var wsId = root.savedWorkspaces[monName]
                if (wsId !== undefined) {
                    batch += "dispatch focusmonitor " + monName + "; dispatch workspace " + wsId + "; "
                }
            }
            if (batch.length > 0) {
                Quickshell.execDetached(["hyprctl", "--batch", batch + "reload"])
            }
        }
    }

    lockSurface: LockSurface {
        context: root.context
    }

    Connections {
        target: GlobalStates
        function onScreenLockedChanged() {
            if (GlobalStates.screenLocked) {
                var next = {}
                var batch = "keyword animation workspaces,1,7,menu_decel,slidevert; "
                for (var i = 0; i < Quickshell.screens.length; ++i) {
                    var mon = Quickshell.screens[i].name
                    var mData = HyprlandData.monitors.find(m => m.name === mon)
                    var ws = (mData?.activeWorkspace?.id ?? 1)
                    next[mon] = ws
                    batch += "dispatch focusmonitor " + mon + "; dispatch workspace " + (2147483647 - ws) + "; "
                }
                root.savedWorkspaces = next
                Quickshell.execDetached(["hyprctl", "--batch", batch + "reload"])
            } else {
                restoreTimer.start()
            }
        }
    }

    Variants {
        model: Quickshell.screens
        delegate: Scope {
            required property ShellScreen modelData
            property bool shouldPush: GlobalStates.screenLocked
            property string targetMonitorName: modelData.name
            property int verticalMovementDistance: modelData.height
            property int horizontalSqueeze: modelData.width * 0.2
        }
    }
}
