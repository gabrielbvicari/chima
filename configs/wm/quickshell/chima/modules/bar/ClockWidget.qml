pragma ComponentBehavior: Bound
import qs.modules.common
import qs.modules.common.widgets
import qs.services
import Quickshell
import QtQuick
import QtQuick.Layouts

MouseArea {
    id: root
    property bool borderless: Config.options.bar.borderless
    property bool showDate: Config.options.bar.verbose
    implicitWidth: rowLayout.implicitWidth + 30
    implicitHeight: rowLayout.implicitHeight
    Layout.fillHeight: true

    hoverEnabled: true

    RowLayout {
        id: rowLayout
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4


        StyledText {
            font.pixelSize: Appearance.font.pixelSize.small
            color: Appearance.colors.colOnLayer1
            text: DateTime.time
            Layout.alignment: Qt.AlignVCenter
        }

        StyledText {
            visible: root.showDate
            font.pixelSize: Appearance.font.pixelSize.small
            color: Appearance.colors.colOnLayer1
            text: "•"
            Layout.alignment: Qt.AlignVCenter
        }

        StyledText {
            visible: root.showDate
            font.pixelSize: Appearance.font.pixelSize.small
            color: Appearance.colors.colOnLayer1
            text: DateTime.date
            Layout.alignment: Qt.AlignVCenter
        }

    }

    LazyLoader {
        id: popupLoader
        active: root.containsMouse

        component: PopupWindow {
            id: popupWindow
            visible: true
            implicitWidth: clockPopup.implicitWidth
            implicitHeight: clockPopup.implicitHeight
            anchor.item: root
            anchor.edges: Edges.Top
            anchor.rect.x: (root.implicitWidth - popupWindow.implicitWidth) / 2
            anchor.rect.y: Config.options.bar.bottom ?
                (-clockPopup.implicitHeight - Appearance.sizes.hyprlandGapsOut) :
                (root.implicitHeight + Appearance.sizes.hyprlandGapsOut + 11)
            color: "transparent"
            ClockPopup {
                id: clockPopup
            }
        }
    }

}
