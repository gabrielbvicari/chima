import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import Quickshell
import QtQuick
import QtQuick.Layouts

Item {
    id: root
    required property string iconName
    required property double downSpeed
    required property double upSpeed
    property bool shown: true
    property bool hovered: false
    clip: true
    visible: width > 0 && height > 0
    implicitWidth: resourceRowLayout.x < 0 ? 0 : childrenRect.width
    implicitHeight: resourceRowLayout.implicitHeight

    function formatSpeed(bytes) {
        if (bytes < 1024) return Math.round(bytes) + "B/s"
        if (bytes < 1024 * 1024) return Math.round(bytes / 1024) + "K/s"
        return Math.round(bytes / (1024 * 1024)) + "M/s"
    }

    function formatSpeedDetailed(bytes) {
        if (bytes < 1024) return bytes.toFixed(0) + " B/s"
        if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + " KB/s"
        return (bytes / (1024 * 1024)).toFixed(2) + " MB/s"
    }

    function formatBytes(bytes) {
        if (bytes < 1024) return Math.round(bytes) + " B"
        if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + " KB"
        if (bytes < 1024 * 1024 * 1024) return (bytes / (1024 * 1024)).toFixed(1) + " MB"
        return (bytes / (1024 * 1024 * 1024)).toFixed(2) + " GB"
    }

    function formatNumber(num) {
        return Math.floor(num).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")
    }

    HoverHandler {
        id: hoverHandler
        onHoveredChanged: root.hovered = hoverHandler.hovered
    }

    RowLayout {
        spacing: 4
        id: resourceRowLayout
        anchors.verticalCenter: parent.verticalCenter
        x: shown ? 0 : -resourceRowLayout.width

        CircularProgress {
            Layout.alignment: Qt.AlignVCenter
            lineWidth: 2
            value: Math.min(1, Math.max(downSpeed, upSpeed) / (100 * 1024 * 1024))
            size: 26
            secondaryColor: Appearance.colors.colSecondaryContainer
            primaryColor: Appearance.m3colors.m3onSecondaryContainer

            MaterialSymbol {
                anchors.centerIn: parent
                fill: 1
                text: iconName
                iconSize: Appearance.font.pixelSize.normal
                color: Appearance.m3colors.m3onSecondaryContainer
            }
        }

        Column {
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 45
            spacing: -2

            StyledText {
                width: parent.width
                color: Appearance.colors.colOnLayer1
                font.pixelSize: 9
                text: "↓" + formatSpeed(downSpeed)
                horizontalAlignment: Text.AlignHCenter
            }

            StyledText {
                width: parent.width
                color: Appearance.colors.colOnLayer1
                font.pixelSize: 9
                text: "↑" + formatSpeed(upSpeed)
                horizontalAlignment: Text.AlignHCenter
            }
        }

        Behavior on x {
            animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
        }
    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Appearance.animation.elementMove.duration
            easing.type: Appearance.animation.elementMove.type
            easing.bezierCurve: Appearance.animation.elementMove.bezierCurve
        }
    }

    LazyLoader {
        active: hovered

        component: PopupWindow {
            id: popupWindow
            visible: true
            implicitWidth: popupContent.implicitWidth
            implicitHeight: popupContent.implicitHeight
            anchor.item: root
            anchor.edges: Edges.Top
            anchor.rect.x: (root.implicitWidth - popupWindow.implicitWidth) / 2
            anchor.rect.y: Config.options.bar.bottom ?
                (-popupContent.implicitHeight - Appearance.sizes.hyprlandGapsOut) :
                (root.implicitHeight + Appearance.sizes.hyprlandGapsOut + 7)
            color: "transparent"

            Rectangle {
                id: popupContent
                readonly property real margin: 15
                implicitWidth: contentLayout.implicitWidth + margin * 2
                implicitHeight: contentLayout.implicitHeight + margin * 2
                color: Appearance.colors.colLayer0
                radius: Appearance.rounding.small
                border.width: 1
                border.color: Appearance.m3colors.m3outlineVariant

                ColumnLayout {
                    id: contentLayout
                    anchors.centerIn: parent
                    spacing: 10

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 5
                        MaterialSymbol {
                            fill: 1
                            text: iconName
                            iconSize: Appearance.font.pixelSize.huge
                            color: Appearance.m3colors.m3onSecondaryContainer
                        }
                        StyledText {
                            text: "Network"
                            font.pixelSize: Appearance.font.pixelSize.title
                            font.family: Appearance.font.family.title
                            color: Appearance.colors.colOnLayer0
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 300
                        Layout.preferredHeight: networkDetailsLayout.implicitHeight + 15
                        radius: Appearance.rounding.small
                        color: Appearance.colors.colLayer1

                        GridLayout {
                            id: networkDetailsLayout
                            anchors.fill: parent
                            anchors.margins: 10
                            columns: 2
                            rowSpacing: 8
                            columnSpacing: 45

                            StyledText {
                                text: "Interface:"
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                color: Appearance.colors.colOnLayer1
                            }
                            StyledText {
                                text: ResourceUsage.networkInterface || "Unknown"
                                font.pixelSize: Appearance.font.pixelSize.small
                                color: Appearance.colors.colOnLayer1
                            }

                            StyledText {
                                text: "IP Address:"
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                color: Appearance.colors.colOnLayer1
                            }
                            StyledText {
                                text: ResourceUsage.networkIpAddress || "N/A"
                                font.pixelSize: Appearance.font.pixelSize.small
                                color: Appearance.colors.colOnLayer1
                            }

                            StyledText {
                                text: "MAC Address:"
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                color: Appearance.colors.colOnLayer1
                            }
                            StyledText {
                                text: ResourceUsage.networkMacAddress || "N/A"
                                font.pixelSize: Appearance.font.pixelSize.small
                                color: Appearance.colors.colOnLayer1
                            }

                            StyledText {
                                text: "Link Speed:"
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                color: Appearance.colors.colOnLayer1
                            }
                            StyledText {
                                text: ResourceUsage.networkLinkSpeed > 0 ? ResourceUsage.networkLinkSpeed + " Mbps" : "N/A"
                                font.pixelSize: Appearance.font.pixelSize.small
                                color: Appearance.colors.colOnLayer1
                            }

                            StyledText {
                                text: "Link State:"
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                color: Appearance.colors.colOnLayer1
                            }
                            StyledText {
                                text: ResourceUsage.networkLinkState === "up" ? "Connected" : (ResourceUsage.networkLinkState === "down" ? "Disconnected" : "N/A")
                                font.pixelSize: Appearance.font.pixelSize.small
                                color: Appearance.colors.colOnLayer1
                            }

                            StyledText {
                                text: "MTU:"
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                color: Appearance.colors.colOnLayer1
                            }
                            StyledText {
                                text: ResourceUsage.networkMtu > 0 ? ResourceUsage.networkMtu + " bytes" : "N/A"
                                font.pixelSize: Appearance.font.pixelSize.small
                                color: Appearance.colors.colOnLayer1
                            }

                            StyledText {
                                text: "Download Speed:"
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                color: Appearance.colors.colOnLayer1
                            }
                            StyledText {
                                text: formatSpeedDetailed(downSpeed)
                                font.pixelSize: Appearance.font.pixelSize.small
                                color: Appearance.colors.colOnLayer1
                            }

                            StyledText {
                                text: "Upload Speed:"
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                color: Appearance.colors.colOnLayer1
                            }
                            StyledText {
                                text: formatSpeedDetailed(upSpeed)
                                font.pixelSize: Appearance.font.pixelSize.small
                                color: Appearance.colors.colOnLayer1
                            }

                            StyledText {
                                text: "Total Downloaded:"
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                color: Appearance.colors.colOnLayer1
                            }
                            StyledText {
                                text: formatBytes(ResourceUsage.networkTotalDownloaded)
                                font.pixelSize: Appearance.font.pixelSize.small
                                color: Appearance.colors.colOnLayer1
                            }

                            StyledText {
                                text: "Total Uploaded:"
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                color: Appearance.colors.colOnLayer1
                            }
                            StyledText {
                                text: formatBytes(ResourceUsage.networkTotalUploaded)
                                font.pixelSize: Appearance.font.pixelSize.small
                                color: Appearance.colors.colOnLayer1
                            }

                            StyledText {
                                text: "Packets Received:"
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                color: Appearance.colors.colOnLayer1
                            }
                            StyledText {
                                text: formatNumber(ResourceUsage.networkPacketsReceived)
                                font.pixelSize: Appearance.font.pixelSize.small
                                color: Appearance.colors.colOnLayer1
                            }

                            StyledText {
                                text: "Packets Sent:"
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                color: Appearance.colors.colOnLayer1
                            }
                            StyledText {
                                text: formatNumber(ResourceUsage.networkPacketsSent)
                                font.pixelSize: Appearance.font.pixelSize.small
                                color: Appearance.colors.colOnLayer1
                            }

                            StyledText {
                                text: "Errors:"
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                color: Appearance.colors.colOnLayer1
                            }
                            StyledText {
                                text: formatNumber(ResourceUsage.networkErrors)
                                font.pixelSize: Appearance.font.pixelSize.small
                                color: Appearance.colors.colOnLayer1
                            }

                            StyledText {
                                text: "Dropped:"
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                color: Appearance.colors.colOnLayer1
                            }
                            StyledText {
                                text: formatNumber(ResourceUsage.networkDropped)
                                font.pixelSize: Appearance.font.pixelSize.small
                                color: Appearance.colors.colOnLayer1
                            }
                        }
                    }
                }
            }
        }
    }
}
