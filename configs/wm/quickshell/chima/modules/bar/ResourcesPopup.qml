import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets

import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    readonly property real margin: 10
    implicitWidth: columnLayout.implicitWidth + margin * 2
    implicitHeight: columnLayout.implicitHeight + margin * 2
    color: Appearance.colors.colLayer0
    radius: Appearance.rounding.small
    border.width: 1
    border.color: Appearance.m3colors.m3outlineVariant
    clip: true

    function formatBytes(bytes) {
        if (bytes < 1024) return Math.round(bytes) + " B"
        if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + " KB"
        if (bytes < 1024 * 1024 * 1024) return (bytes / (1024 * 1024)).toFixed(1) + " MB"
        return (bytes / (1024 * 1024 * 1024)).toFixed(2) + " GB"
    }

    function formatSpeed(bytes) {
        if (bytes < 1024) return bytes.toFixed(0) + " B/s"
        if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + " KB/s"
        return (bytes / (1024 * 1024)).toFixed(2) + " MB/s"
    }

    ColumnLayout {
        id: columnLayout
        spacing: 10
        anchors.centerIn: root

        // Header
        RowLayout {
            spacing: 5
            Layout.alignment: Qt.AlignHCenter

            MaterialSymbol {
                fill: 1
                text: "memory"
                iconSize: Appearance.font.pixelSize.huge
                color: Appearance.m3colors.m3onSecondaryContainer
            }

            StyledText {
                text: "System Resources"
                font.pixelSize: Appearance.font.pixelSize.title
                font.family: Appearance.font.family.title
                color: Appearance.colors.colOnLayer0
            }
        }

        // Resources grid
        GridLayout {
            columns: 2
            rowSpacing: 5
            columnSpacing: 5
            Layout.alignment: Qt.AlignHCenter
            uniformCellWidths: true

            // CPU
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: cpuInfo.implicitHeight + 15
                radius: Appearance.rounding.small
                color: Appearance.colors.colLayer1

                ColumnLayout {
                    id: cpuInfo
                    anchors.centerIn: parent
                    spacing: 5

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 5
                        MaterialSymbol {
                            fill: 1
                            text: "settings_slow_motion"
                            iconSize: Appearance.font.pixelSize.normal
                            color: Appearance.m3colors.m3onSecondaryContainer
                        }
                        StyledText {
                            text: "CPU"
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: Appearance.colors.colOnLayer1
                        }
                    }
                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: Math.round(ResourceUsage.cpuUsage * 100) + "%"
                        font.pixelSize: Appearance.font.pixelSize.large
                        font.bold: true
                        color: Appearance.colors.colOnLayer1
                    }
                }
            }

            // Memory
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: memInfo.implicitHeight + 15
                radius: Appearance.rounding.small
                color: Appearance.colors.colLayer1

                ColumnLayout {
                    id: memInfo
                    anchors.centerIn: parent
                    spacing: 5

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 5
                        MaterialSymbol {
                            fill: 1
                            text: "memory"
                            iconSize: Appearance.font.pixelSize.normal
                            color: Appearance.m3colors.m3onSecondaryContainer
                        }
                        StyledText {
                            text: "Memory"
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: Appearance.colors.colOnLayer1
                        }
                    }
                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: formatBytes(ResourceUsage.memoryUsed * 1024)
                        font.pixelSize: Appearance.font.pixelSize.normal
                        font.bold: true
                        color: Appearance.colors.colOnLayer1
                    }
                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: Math.round(ResourceUsage.memoryUsedPercentage * 100) + "%"
                        font.pixelSize: Appearance.font.pixelSize.small
                        color: Appearance.colors.colOnLayer1
                    }
                }
            }

            // Swap
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: swapInfo.implicitHeight + 15
                radius: Appearance.rounding.small
                color: Appearance.colors.colLayer1

                ColumnLayout {
                    id: swapInfo
                    anchors.centerIn: parent
                    spacing: 5

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 5
                        MaterialSymbol {
                            fill: 1
                            text: "swap_horiz"
                            iconSize: Appearance.font.pixelSize.normal
                            color: Appearance.m3colors.m3onSecondaryContainer
                        }
                        StyledText {
                            text: "Swap"
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: Appearance.colors.colOnLayer1
                        }
                    }
                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: formatBytes(ResourceUsage.swapUsed * 1024)
                        font.pixelSize: Appearance.font.pixelSize.normal
                        font.bold: true
                        color: Appearance.colors.colOnLayer1
                    }
                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: Math.round(ResourceUsage.swapUsedPercentage * 100) + "%"
                        font.pixelSize: Appearance.font.pixelSize.small
                        color: Appearance.colors.colOnLayer1
                    }
                }
            }

            // Disk
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: diskInfo.implicitHeight + 15
                radius: Appearance.rounding.small
                color: Appearance.colors.colLayer1

                ColumnLayout {
                    id: diskInfo
                    anchors.centerIn: parent
                    spacing: 5

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 5
                        MaterialSymbol {
                            fill: 1
                            text: "storage"
                            iconSize: Appearance.font.pixelSize.normal
                            color: Appearance.m3colors.m3onSecondaryContainer
                        }
                        StyledText {
                            text: "Disk"
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: Appearance.colors.colOnLayer1
                        }
                    }
                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: Math.round(ResourceUsage.diskUsedPercentage * 100) + "%"
                        font.pixelSize: Appearance.font.pixelSize.large
                        font.bold: true
                        color: Appearance.colors.colOnLayer1
                    }
                }
            }

            // Network Download
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: downloadInfo.implicitHeight + 15
                radius: Appearance.rounding.small
                color: Appearance.colors.colLayer1

                ColumnLayout {
                    id: downloadInfo
                    anchors.centerIn: parent
                    spacing: 5

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 5
                        MaterialSymbol {
                            fill: 0
                            text: "download"
                            iconSize: Appearance.font.pixelSize.normal
                            color: Appearance.m3colors.m3primary
                        }
                        StyledText {
                            text: "Download"
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: Appearance.colors.colOnLayer1
                        }
                    }
                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: formatSpeed(ResourceUsage.networkDownSpeed)
                        font.pixelSize: Appearance.font.pixelSize.normal
                        font.bold: true
                        color: Appearance.colors.colOnLayer1
                    }
                }
            }

            // Network Upload
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: uploadInfo.implicitHeight + 15
                radius: Appearance.rounding.small
                color: Appearance.colors.colLayer1

                ColumnLayout {
                    id: uploadInfo
                    anchors.centerIn: parent
                    spacing: 5

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 5
                        MaterialSymbol {
                            fill: 0
                            text: "upload"
                            iconSize: Appearance.font.pixelSize.normal
                            color: Appearance.m3colors.m3tertiary
                        }
                        StyledText {
                            text: "Upload"
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: Appearance.colors.colOnLayer1
                        }
                    }
                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: formatSpeed(ResourceUsage.networkUpSpeed)
                        font.pixelSize: Appearance.font.pixelSize.normal
                        font.bold: true
                        color: Appearance.colors.colOnLayer1
                    }
                }
            }
        }
    }
}
