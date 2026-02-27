import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions

Button {
    id: root

    // Properties
    property bool toggled: false
    property string buttonText: ""
    property bool leftmost: false
    property bool rightmost: false

    // Padding
    horizontalPadding: 12
    verticalPadding: 8

    // Sizing
    implicitWidth: contentItem.implicitWidth + leftPadding + rightPadding
    implicitHeight: contentItem.implicitHeight + topPadding + bottomPadding

    // Radius properties
    property real leftRadius: (toggled || leftmost) ? (height / 2) : Appearance.rounding.unsharpenmore
    property real rightRadius: (toggled || rightmost) ? (height / 2) : Appearance.rounding.unsharpenmore

    // Colors
    property color bgColor: root.enabled ? (root.toggled ?
        (root.down ? Appearance.colors.colPrimaryActive :
            root.hovered ? Appearance.colors.colPrimaryHover :
            Appearance.colors.colPrimary) :
        (root.down ? Appearance.colors.colLayer1Active :
            root.hovered ? Appearance.colors.colLayer1Hover :
            Appearance.colors.colSecondaryContainer)) : Appearance.colors.colSecondaryContainer

    // Background
    background: Rectangle {
        topLeftRadius: root.leftRadius
        topRightRadius: root.rightRadius
        bottomLeftRadius: root.leftRadius
        bottomRightRadius: root.rightRadius
        color: root.bgColor

        Behavior on color {
            animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
        }
    }

    Behavior on leftRadius {
        animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
    }
    Behavior on rightRadius {
        animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
    }

    // Content - Text centered in the button
    contentItem: Text {
        text: root.buttonText

        // Styling
        renderType: Text.NativeRendering
        font {
            hintingPreference: Font.PreferFullHinting
            family: Appearance?.font.family.main ?? "sans-serif"
            pixelSize: Appearance?.font.pixelSize.small ?? 15
        }
        color: root.toggled ? Appearance.colors.colOnPrimary : Appearance.colors.colOnSecondaryContainer

        // Centering
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        // Fill available space to make centering work
        width: root.width - root.leftPadding - root.rightPadding
        height: root.height - root.topPadding - root.bottomPadding

        elide: Text.ElideRight
    }

    // Cursor styling
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.NoButton
    }
}
