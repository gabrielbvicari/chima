import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.modules.common
import qs.modules.overlay

StyledOverlayWidget {
    id: root
    fancyBorders: false
    showCenterButton: true
    opacity: 1
    showClickabilityButton: false
    clickthrough: true
    resizable: false

    contentItem: CrosshairContent {
        anchors.centerIn: parent
    }
}
