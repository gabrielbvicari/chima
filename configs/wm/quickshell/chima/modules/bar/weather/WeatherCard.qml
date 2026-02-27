import QtQuick
import QtQuick.Layouts

import qs.modules.common
import qs.modules.common.widgets

Rectangle {
    id: root
    radius: Appearance.rounding.small
    color: Appearance.colors.colLayer1
    Layout.fillWidth: true
    Layout.preferredHeight: 60
    Layout.alignment: Qt.AlignCenter

    property alias title: title.text
    property alias value: value.text
    property alias symbol: symbol.text

    ColumnLayout {
        id: columnLayout
        anchors.centerIn: parent
        spacing: 0
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 3
            MaterialSymbol {
                id: symbol
                fill: 0
                iconSize: Appearance.font.pixelSize.normal
            }
            StyledText {
                id: title
                font.pixelSize: Appearance.font.pixelSize.smaller
                color: Appearance.colors.colOnLayer1
            }
        }
        StyledText {
            id: value
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: Appearance.font.pixelSize.normal
            color: Appearance.colors.colOnLayer1
        }
    }
}
