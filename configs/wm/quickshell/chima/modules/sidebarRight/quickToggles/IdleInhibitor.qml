import qs.modules.common
import qs.modules.common.widgets
import qs
import Quickshell.Io
import Quickshell
import QtQuick

QuickToggleButton {
    id: root
    toggled: false
    buttonIcon: "coffee"
    onClicked: {
        if (toggled) {
            Quickshell.execDetached(["pkill", "wayland-idle"]) // pkill doesn't accept too long names
            checkTimer.start()
        } else {
            Quickshell.execDetached([`${Directories.scriptPath}/wayland-idle-inhibitor.py`])
            checkTimer.start()
        }
    }

    Process {
        id: fetchActiveState
        running: false
        command: ["pidof", "wayland-idle-inhibitor.py"]
        onExited: (exitCode, exitStatus) => {
            root.toggled = exitCode === 0
        }
    }

    Timer {
        id: checkTimer
        interval: 500
        repeat: false
        onTriggered: fetchActiveState.running = true
    }

    Component.onCompleted: fetchActiveState.running = true

    StyledToolTip {
        content: Translation.tr("Keep System Awake")
    }
}
