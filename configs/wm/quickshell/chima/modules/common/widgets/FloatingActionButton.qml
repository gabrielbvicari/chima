import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import Qt5Compat.GraphicalEffects

/**
 * Material 3 FAB - Reimplemented for reliable click handling
 */
Item {
    id: root
    property string iconText: "add"
    property string buttonText: ""
    property bool expanded: false
    property real baseSize: 56
    property Component contentItem: null  // Allow custom content override

    signal clicked()

    implicitWidth: expanded ? 150 : baseSize
    implicitHeight: baseSize

    // Internal state
    property bool hovered: false
    property bool pressed: false

    // Colors
    property color bgColor: hovered ?
        Appearance.colors.colPrimaryContainerHover :
        Appearance.colors.colPrimaryContainer
    property color rippleColor: Appearance.colors.colPrimaryContainerActive

    Behavior on implicitWidth {
        animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
    }

    // Background
    Rectangle {
        id: background
        anchors.fill: parent
        radius: Appearance.rounding.small
        color: root.bgColor

        Behavior on color {
            animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
        }

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: background.width
                height: background.height
                radius: Appearance.rounding.small
            }
        }

        // Ripple effect
        Item {
            id: ripple
            width: ripple.rippleSize
            height: ripple.rippleSize
            opacity: 0
            visible: width > 0 && height > 0

            property real rippleSize: 0
            property real rippleX: 0
            property real rippleY: 0

            x: rippleX - width / 2
            y: rippleY - height / 2

            Behavior on opacity {
                animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
            }

            RadialGradient {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: root.rippleColor }
                    GradientStop { position: 0.3; color: root.rippleColor }
                    GradientStop { position: 0.5; color: Qt.rgba(root.rippleColor.r, root.rippleColor.g, root.rippleColor.b, 0) }
                }
            }
        }
    }

    // Mouse handling - MUST be before content to ensure it receives events
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        z: 100  // Ensure it's on top

        onEntered: root.hovered = true
        onExited: root.hovered = false

        onPressed: (mouse) => {
            root.pressed = true

            // Start ripple
            ripple.rippleX = mouse.x
            ripple.rippleY = mouse.y
            ripple.opacity = 1

            // Calculate ripple radius
            const dist = (ox, oy) => Math.sqrt(ox*ox + oy*oy)
            ripple.rippleSize = Math.max(
                dist(mouse.x, mouse.y),
                dist(root.width - mouse.x, mouse.y),
                dist(mouse.x, root.height - mouse.y),
                dist(root.width - mouse.x, root.height - mouse.y)
            ) * 2

            rippleAnim.restart()
        }

        onReleased: {
            root.pressed = false
            rippleFadeAnim.restart()
        }

        onClicked: root.clicked()
    }

    // Content
    Item {
        anchors.fill: parent
        z: 1  // Below MouseArea

        // If custom contentItem provided, use that instead of default
        Loader {
            anchors.fill: parent
            active: root.contentItem !== null
            sourceComponent: root.contentItem
        }

        // Default content (icon + optional text)
        Item {
            anchors.fill: parent
            visible: root.contentItem === null

            Item {
                id: iconContainer
                width: root.baseSize
                height: root.baseSize
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }

                MaterialSymbol {
                    anchors.centerIn: parent
                    iconSize: 24
                    color: Appearance.colors.colOnPrimaryContainer
                    text: root.iconText
                }
            }

            Loader {
                active: root.expanded
                anchors {
                    left: iconContainer.right
                    verticalCenter: parent.verticalCenter
                }
                sourceComponent: StyledText {
                    text: root.buttonText
                    color: Appearance.colors.colOnPrimaryContainer
                    font.pixelSize: 14
                    font.weight: 450
                }
            }
        }
    }

    // Ripple animations
    NumberAnimation {
        id: rippleAnim
        target: ripple
        property: "rippleSize"
        from: 0
        to: ripple.rippleSize
        duration: 600
        easing.type: Appearance.animation.elementMoveEnter.type
        easing.bezierCurve: Appearance.animationCurves.standardDecel
    }

    NumberAnimation {
        id: rippleFadeAnim
        target: ripple
        property: "opacity"
        to: 0
        duration: 300
    }
}
