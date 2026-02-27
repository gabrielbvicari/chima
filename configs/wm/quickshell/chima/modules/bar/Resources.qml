pragma ComponentBehavior: Bound
import qs.modules.common
import qs.modules.common.widgets
import qs.services
import Quickshell
import QtQuick
import QtQuick.Layouts

Item {
    id: root
    property bool borderless: Config.options.bar.borderless
    property bool alwaysShowAllResources: false
    implicitWidth: rowLayout.implicitWidth + rowLayout.anchors.leftMargin + rowLayout.anchors.rightMargin
    implicitHeight: 32

    RowLayout {
        id: rowLayout

        spacing: 0
        anchors.fill: parent
        anchors.leftMargin: 4
        anchors.rightMargin: 4

        Resource {
            iconName: "settings_slow_motion"
            percentage: ResourceUsage.cpuUsage
            resourceName: "CPU"
        }

        Resource {
            iconName: "memory"
            percentage: ResourceUsage.memoryUsedPercentage
            resourceName: "Memory"
            resourceBytes: ResourceUsage.memoryUsed
            Layout.leftMargin: 4
        }

        Resource {
            iconName: "swap_horiz"
            percentage: ResourceUsage.swapUsedPercentage
            resourceName: "Swap"
            resourceBytes: ResourceUsage.swapUsed
            Layout.leftMargin: 4
        }

        Resource {
            iconName: "storage"
            percentage: ResourceUsage.diskUsedPercentage
            resourceName: "Disk"
            Layout.leftMargin: 4
        }

        NetworkResource {
            iconName: "wifi"
            downSpeed: ResourceUsage.networkDownSpeed
            upSpeed: ResourceUsage.networkUpSpeed
            Layout.leftMargin: 4
        }

    }

}
