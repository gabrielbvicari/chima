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
    required property double percentage
    required property string resourceName
    property double resourceBytes: 0
    property bool shown: true
    property bool hovered: false
    clip: true
    visible: width > 0 && height > 0
    implicitWidth: resourceRowLayout.x < 0 ? 0 : childrenRect.width
    implicitHeight: resourceRowLayout.implicitHeight

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
            value: percentage
            implicitSize: 26
            colSecondary: Appearance.colors.colSecondaryContainer
            colPrimary: Appearance.m3colors.m3onSecondaryContainer

            MaterialSymbol {
                anchors.centerIn: parent
                fill: 1
                text: iconName
                iconSize: Appearance.font.pixelSize.normal
                color: Appearance.m3colors.m3onSecondaryContainer
            }

        }

        StyledText {
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 35
            color: Appearance.colors.colOnLayer1
            text: `${Math.round(percentage * 100)}%`
            horizontalAlignment: Text.AlignHCenter
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
                            text: resourceName
                            font.pixelSize: Appearance.font.pixelSize.title
                            font.family: Appearance.font.family.title
                            color: Appearance.colors.colOnLayer0
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: usageInfo.implicitHeight + 15
                        radius: Appearance.rounding.small
                        color: Appearance.colors.colLayer1

                        ColumnLayout {
                            id: usageInfo
                            anchors.centerIn: parent
                            spacing: 8

                            StyledText {
                                Layout.alignment: Qt.AlignHCenter
                                text: Math.round(percentage * 100) + "%"
                                font.pixelSize: Appearance.font.pixelSize.huge
                                color: Appearance.colors.colOnLayer1
                            }

                            Rectangle {
                                Layout.alignment: Qt.AlignHCenter
                                Layout.preferredWidth: 200
                                Layout.preferredHeight: 8
                                radius: 4
                                color: Appearance.colors.colSecondaryContainer

                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.top: parent.top
                                    anchors.bottom: parent.bottom
                                    width: parent.width * percentage
                                    radius: 4
                                    color: Appearance.m3colors.m3primary
                                }
                            }

                            StyledText {
                                Layout.alignment: Qt.AlignHCenter
                                text: resourceBytes > 0 ? formatBytes(resourceBytes * 1024) + " used" : ""
                                font.pixelSize: Appearance.font.pixelSize.small
                                color: Appearance.colors.colOnLayer1
                                visible: resourceBytes > 0
                            }
                        }
                    }

                    Loader {
                        active: resourceName === "CPU"
                        visible: active
                        Layout.fillWidth: true

                        sourceComponent: ColumnLayout {
                            spacing: 10

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredWidth: 300
                                Layout.preferredHeight: cpuDetailsLayout.implicitHeight + 15
                                radius: Appearance.rounding.small
                                color: Appearance.colors.colLayer1

                                GridLayout {
                                    id: cpuDetailsLayout
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    columns: 2
                                    rowSpacing: 8
                                    columnSpacing: 25

                                    StyledText {
                                        text: "Model:"
                                        font.pixelSize: Appearance.font.pixelSize.smaller
                                        color: Appearance.colors.colOnLayer1
                                        Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                                    }
                                    StyledText {
                                        text: ResourceUsage.cpuModel || "Unknown"
                                        font.pixelSize: Appearance.font.pixelSize.small
                                        color: Appearance.colors.colOnLayer1
                                        Layout.fillWidth: true
                                        Layout.maximumWidth: 200
                                        wrapMode: Text.WordWrap
                                        elide: Text.ElideRight
                                        maximumLineCount: 2
                                    }

                                    StyledText {
                                        text: "Cores:"
                                        font.pixelSize: Appearance.font.pixelSize.smaller
                                        color: Appearance.colors.colOnLayer1
                                    }
                                    StyledText {
                                        text: ResourceUsage.cpuCoreCount.toString()
                                        font.pixelSize: Appearance.font.pixelSize.small
                                        color: Appearance.colors.colOnLayer1
                                    }

                                    StyledText {
                                        text: "Temperature:"
                                        font.pixelSize: Appearance.font.pixelSize.smaller
                                        color: Appearance.colors.colOnLayer1
                                        visible: ResourceUsage.cpuTemperature > 0
                                    }
                                    StyledText {
                                        text: ResourceUsage.cpuTemperature.toFixed(1) + "°C"
                                        font.pixelSize: Appearance.font.pixelSize.small
                                        color: Appearance.colors.colOnLayer1
                                        visible: ResourceUsage.cpuTemperature > 0
                                    }

                                    StyledText {
                                        text: "Frequency:"
                                        font.pixelSize: Appearance.font.pixelSize.smaller
                                        color: Appearance.colors.colOnLayer1
                                        visible: ResourceUsage.cpuCoreFrequencies.length > 0
                                    }
                                    StyledText {
                                        text: {
                                            if (ResourceUsage.cpuCoreFrequencies.length === 0) return ""
                                            const avg = ResourceUsage.cpuCoreFrequencies.reduce((a, b) => a + b, 0) / ResourceUsage.cpuCoreFrequencies.length
                                            return (avg / 1000000).toFixed(2) + " GHz"
                                        }
                                        font.pixelSize: Appearance.font.pixelSize.small
                                        color: Appearance.colors.colOnLayer1
                                        visible: ResourceUsage.cpuCoreFrequencies.length > 0
                                    }
                                }
                            }

                            StyledText {
                                Layout.alignment: Qt.AlignHCenter
                                text: "Per-Core Usage"
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                color: Appearance.colors.colOnLayer0
                                Layout.topMargin: 5
                            }

                            GridLayout {
                                columns: Math.min(4, ResourceUsage.cpuCoreUsages.length)
                                rowSpacing: 5
                                columnSpacing: 5
                                Layout.alignment: Qt.AlignHCenter

                                Repeater {
                                    model: ResourceUsage.cpuCoreUsages

                                    Rectangle {
                                        Layout.preferredWidth: 70
                                        Layout.preferredHeight: coreInfo.implicitHeight + 10
                                        radius: Appearance.rounding.small
                                        color: Appearance.colors.colLayer1

                                        ColumnLayout {
                                            id: coreInfo
                                            anchors.centerIn: parent
                                            spacing: 3

                                            StyledText {
                                                Layout.alignment: Qt.AlignHCenter
                                                text: "Core " + index
                                                font.pixelSize: Appearance.font.pixelSize.smaller
                                                color: Appearance.colors.colOnLayer1
                                            }

                                            StyledText {
                                                Layout.alignment: Qt.AlignHCenter
                                                text: Math.round(modelData * 100) + "%"
                                                font.pixelSize: Appearance.font.pixelSize.normal
                                                color: Appearance.colors.colOnLayer1
                                            }

                                            Rectangle {
                                                Layout.alignment: Qt.AlignHCenter
                                                Layout.preferredWidth: 50
                                                Layout.preferredHeight: 4
                                                radius: 2
                                                color: Appearance.colors.colSecondaryContainer

                                                Rectangle {
                                                    anchors.left: parent.left
                                                    anchors.top: parent.top
                                                    anchors.bottom: parent.bottom
                                                    width: parent.width * modelData
                                                    radius: 2
                                                    color: Appearance.m3colors.m3primary
                                                }
                                            }

                                            StyledText {
                                                Layout.alignment: Qt.AlignHCenter
                                                text: {
                                                    if (ResourceUsage.cpuCoreFrequencies.length > index) {
                                                        return (ResourceUsage.cpuCoreFrequencies[index] / 1000000).toFixed(2) + " GHz"
                                                    }
                                                    return ""
                                                }
                                                font.pixelSize: 8
                                                color: Appearance.colors.colOnLayer1
                                                visible: ResourceUsage.cpuCoreFrequencies.length > index
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Loader {
                        active: resourceName === "Memory" || resourceName === "Swap"
                        visible: active
                        Layout.fillWidth: true

                        sourceComponent: ColumnLayout {
                            spacing: 10

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredWidth: 300
                                Layout.preferredHeight: memDetailsLayout.implicitHeight + 15
                                radius: Appearance.rounding.small
                                color: Appearance.colors.colLayer1

                                GridLayout {
                                    id: memDetailsLayout
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    columns: 2
                                    rowSpacing: 8
                                    columnSpacing: resourceName === "Memory" ? 150 : 110

                                    StyledText {
                                        text: "Total:"
                                        font.pixelSize: Appearance.font.pixelSize.smaller
                                        color: Appearance.colors.colOnLayer1
                                    }
                                    StyledText {
                                        text: {
                                            if (resourceName === "Memory") return formatBytes(ResourceUsage.memoryTotal * 1024)
                                            if (resourceName === "Swap") return formatBytes(ResourceUsage.swapTotal * 1024)
                                            return ""
                                        }
                                        font.pixelSize: Appearance.font.pixelSize.small
                                        color: Appearance.colors.colOnLayer1
                                    }

                                    StyledText {
                                        text: "Used:"
                                        font.pixelSize: Appearance.font.pixelSize.smaller
                                        color: Appearance.colors.colOnLayer1
                                    }
                                    StyledText {
                                        text: {
                                            if (resourceName === "Memory") return formatBytes(ResourceUsage.memoryUsed * 1024)
                                            if (resourceName === "Swap") return formatBytes(ResourceUsage.swapUsed * 1024)
                                            return ""
                                        }
                                        font.pixelSize: Appearance.font.pixelSize.small
                                        color: Appearance.colors.colOnLayer1
                                    }

                                    StyledText {
                                        text: "Free:"
                                        font.pixelSize: Appearance.font.pixelSize.smaller
                                        color: Appearance.colors.colOnLayer1
                                    }
                                    StyledText {
                                        text: {
                                            if (resourceName === "Memory") return formatBytes(ResourceUsage.memoryFree * 1024)
                                            if (resourceName === "Swap") return formatBytes(ResourceUsage.swapFree * 1024)
                                            return ""
                                        }
                                        font.pixelSize: Appearance.font.pixelSize.small
                                        color: Appearance.colors.colOnLayer1
                                    }

                                    StyledText {
                                        text: "Cached:"
                                        font.pixelSize: Appearance.font.pixelSize.smaller
                                        color: Appearance.colors.colOnLayer1
                                        visible: resourceName === "Memory"
                                    }
                                    StyledText {
                                        text: formatBytes(ResourceUsage.memoryCached * 1024)
                                        font.pixelSize: Appearance.font.pixelSize.small
                                        color: Appearance.colors.colOnLayer1
                                        visible: resourceName === "Memory"
                                    }

                                    StyledText {
                                        text: "Buffers:"
                                        font.pixelSize: Appearance.font.pixelSize.smaller
                                        color: Appearance.colors.colOnLayer1
                                        visible: resourceName === "Memory"
                                    }
                                    StyledText {
                                        text: formatBytes(ResourceUsage.memoryBuffers * 1024)
                                        font.pixelSize: Appearance.font.pixelSize.small
                                        color: Appearance.colors.colOnLayer1
                                        visible: resourceName === "Memory"
                                    }

                                    StyledText {
                                        text: "Shared:"
                                        font.pixelSize: Appearance.font.pixelSize.smaller
                                        color: Appearance.colors.colOnLayer1
                                        visible: resourceName === "Memory"
                                    }
                                    StyledText {
                                        text: formatBytes(ResourceUsage.memoryShared * 1024)
                                        font.pixelSize: Appearance.font.pixelSize.small
                                        color: Appearance.colors.colOnLayer1
                                        visible: resourceName === "Memory"
                                    }

                                    StyledText {
                                        text: "Frequency:"
                                        font.pixelSize: Appearance.font.pixelSize.smaller
                                        color: Appearance.colors.colOnLayer1
                                        visible: resourceName === "Memory" && ResourceUsage.memoryFrequency !== ""
                                    }
                                    StyledText {
                                        text: ResourceUsage.memoryFrequency
                                        font.pixelSize: Appearance.font.pixelSize.small
                                        color: Appearance.colors.colOnLayer1
                                        visible: resourceName === "Memory" && ResourceUsage.memoryFrequency !== ""
                                    }

                                    StyledText {
                                        text: "Swap Cached:"
                                        font.pixelSize: Appearance.font.pixelSize.smaller
                                        color: Appearance.colors.colOnLayer1
                                        visible: resourceName === "Swap"
                                    }
                                    StyledText {
                                        text: formatBytes(ResourceUsage.swapCached * 1024)
                                        font.pixelSize: Appearance.font.pixelSize.small
                                        color: Appearance.colors.colOnLayer1
                                        visible: resourceName === "Swap"
                                    }
                                }
                            }
                        }
                    }

                    Loader {
                        active: resourceName === "Disk"
                        visible: active
                        Layout.fillWidth: true

                        sourceComponent: ColumnLayout {
                            spacing: 10

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredWidth: 300
                                Layout.preferredHeight: diskDetailsLayout.implicitHeight + 15
                                radius: Appearance.rounding.small
                                color: Appearance.colors.colLayer1

                                GridLayout {
                                    id: diskDetailsLayout
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    columns: 2
                                    rowSpacing: 8
                                    columnSpacing: 75

                                    StyledText {
                                        text: "Device:"
                                        font.pixelSize: Appearance.font.pixelSize.smaller
                                        color: Appearance.colors.colOnLayer1
                                    }
                                    StyledText {
                                        text: ResourceUsage.diskDevice || "Unknown"
                                        font.pixelSize: Appearance.font.pixelSize.small
                                        color: Appearance.colors.colOnLayer1
                                    }

                                    StyledText {
                                        text: "Filesystem:"
                                        font.pixelSize: Appearance.font.pixelSize.smaller
                                        color: Appearance.colors.colOnLayer1
                                    }
                                    StyledText {
                                        text: ResourceUsage.diskFilesystem || "Unknown"
                                        font.pixelSize: Appearance.font.pixelSize.small
                                        color: Appearance.colors.colOnLayer1
                                    }

                                    StyledText {
                                        text: "Mount Point:"
                                        font.pixelSize: Appearance.font.pixelSize.smaller
                                        color: Appearance.colors.colOnLayer1
                                    }
                                    StyledText {
                                        text: ResourceUsage.diskMountPoint || "/"
                                        font.pixelSize: Appearance.font.pixelSize.small
                                        color: Appearance.colors.colOnLayer1
                                    }

                                    StyledText {
                                        text: "Total:"
                                        font.pixelSize: Appearance.font.pixelSize.smaller
                                        color: Appearance.colors.colOnLayer1
                                    }
                                    StyledText {
                                        text: formatBytes(ResourceUsage.diskTotal)
                                        font.pixelSize: Appearance.font.pixelSize.small
                                        color: Appearance.colors.colOnLayer1
                                    }

                                    StyledText {
                                        text: "Used:"
                                        font.pixelSize: Appearance.font.pixelSize.smaller
                                        color: Appearance.colors.colOnLayer1
                                    }
                                    StyledText {
                                        text: formatBytes(ResourceUsage.diskUsed)
                                        font.pixelSize: Appearance.font.pixelSize.small
                                        color: Appearance.colors.colOnLayer1
                                    }

                                    StyledText {
                                        text: "Free:"
                                        font.pixelSize: Appearance.font.pixelSize.smaller
                                        color: Appearance.colors.colOnLayer1
                                    }
                                    StyledText {
                                        text: formatBytes(ResourceUsage.diskFree)
                                        font.pixelSize: Appearance.font.pixelSize.small
                                        color: Appearance.colors.colOnLayer1
                                    }

                                    StyledText {
                                        text: "Inodes Total:"
                                        font.pixelSize: Appearance.font.pixelSize.smaller
                                        color: Appearance.colors.colOnLayer1
                                    }
                                    StyledText {
                                        text: formatNumber(ResourceUsage.diskInodesTotal)
                                        font.pixelSize: Appearance.font.pixelSize.small
                                        color: Appearance.colors.colOnLayer1
                                    }

                                    StyledText {
                                        text: "Inodes Free:"
                                        font.pixelSize: Appearance.font.pixelSize.smaller
                                        color: Appearance.colors.colOnLayer1
                                    }
                                    StyledText {
                                        text: formatNumber(ResourceUsage.diskInodesFree)
                                        font.pixelSize: Appearance.font.pixelSize.small
                                        color: Appearance.colors.colOnLayer1
                                    }

                                    StyledText {
                                        text: "Inodes Used:"
                                        font.pixelSize: Appearance.font.pixelSize.smaller
                                        color: Appearance.colors.colOnLayer1
                                    }
                                    StyledText {
                                        text: formatNumber(ResourceUsage.diskInodesUsed) + " (" + Math.round(ResourceUsage.diskInodesUsedPercentage * 100) + "%)"
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
    }
}
