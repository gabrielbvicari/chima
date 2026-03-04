import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets

import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    readonly property real margin: 10
    implicitWidth: 400
    implicitHeight: columnLayout.implicitHeight + margin * 2
    color: Appearance.colors.colLayer0
    radius: Appearance.rounding.small
    border.width: 1
    border.color: Appearance.m3colors.m3outlineVariant
    clip: true

    function getDayOfWeek(year, month, day) {
        return new Date(year, month, day).getDay()
    }

    function getDaysInMonth(year, month) {
        return new Date(year, month + 1, 0).getDate()
    }

    function getFirstDayOfMonth(year, month) {
        return new Date(year, month, 1).getDay()
    }

    function getDaysInPreviousMonth(year, month) {
        return new Date(year, month, 0).getDate()
    }

    property var currentDate: new Date()
    property int currentYear: currentDate.getFullYear()
    property int currentMonth: currentDate.getMonth()
    property int currentDay: currentDate.getDate()
    property int daysInMonth: getDaysInMonth(currentYear, currentMonth)
    property int firstDayOfMonth: getFirstDayOfMonth(currentYear, currentMonth)

    property int dayOfYear: {
        var start = new Date(currentYear, 0, 0);
        var diff = currentDate - start;
        var oneDay = 1000 * 60 * 60 * 24;
        return Math.floor(diff / oneDay);
    }

    property int weekNumber: {
        var d = new Date(Date.UTC(currentYear, currentMonth, currentDay));
        var dayNum = d.getUTCDay() || 7;
        d.setUTCDate(d.getUTCDate() + 4 - dayNum);
        var yearStart = new Date(Date.UTC(d.getUTCFullYear(),0,1));
        return Math.ceil((((d - yearStart) / 86400000) + 1)/7);
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            currentDate = new Date()
        }
    }

    ColumnLayout {
        id: columnLayout
        spacing: 10
        anchors.centerIn: root
        width: root.width - root.margin * 2

        RowLayout {
            spacing: 6
            Layout.alignment: Qt.AlignHCenter

            MaterialSymbol {
                fill: 0
                text: "calendar_month"
                iconSize: Appearance.font.pixelSize.huge
            }

            StyledText {
                text: Qt.locale().toString(currentDate, "MMMM yyyy")
                font.pixelSize: Appearance.font.pixelSize.title
                font.family: Appearance.font.family.title
                color: Appearance.colors.colOnLayer0
            }
        }

        GridLayout {
            id: calendarGrid
            columns: 7
            rowSpacing: 6
            columnSpacing: 6
            Layout.alignment: Qt.AlignHCenter

            Repeater {
                model: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
                StyledText {
                    text: modelData
                    font.pixelSize: Appearance.font.pixelSize.small
                    font.bold: true
                    color: Appearance.colors.colOnLayer0
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    Layout.preferredWidth: 45
                    Layout.preferredHeight: 30
                    Layout.alignment: Qt.AlignCenter
                }
            }

            Repeater {
                model: 42
                Rectangle {
                    Layout.preferredWidth: 45
                    Layout.preferredHeight: 45
                    Layout.alignment: Qt.AlignCenter
                    radius: Appearance.rounding.small

                    property int cellIndex: index
                    property int prevMonthDays: getDaysInPreviousMonth(currentYear, currentMonth)
                    property int dayNumber: {
                        if (cellIndex < firstDayOfMonth) {
                            return prevMonthDays - firstDayOfMonth + cellIndex + 1
                        } else if (cellIndex < firstDayOfMonth + daysInMonth) {
                            return cellIndex - firstDayOfMonth + 1
                        } else {
                            return cellIndex - firstDayOfMonth - daysInMonth + 1
                        }
                    }
                    property bool isCurrentMonth: cellIndex >= firstDayOfMonth && cellIndex < firstDayOfMonth + daysInMonth
                    property bool isToday: isCurrentMonth && dayNumber === currentDay

                    color: isToday ? Appearance.m3colors.m3primary : "transparent"

                    StyledText {
                        anchors.centerIn: parent
                        text: dayNumber
                        font.pixelSize: Appearance.font.pixelSize.normal
                        color: isToday ? Appearance.m3colors.m3onPrimary :
                               isCurrentMonth ? Appearance.colors.colOnLayer0 :
                               Appearance.colors.colOutlineVariant
                    }
                }
            }
        }

        GridLayout {
            columns: 2
            rowSpacing: 6
            columnSpacing: 10
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            Layout.topMargin: 6

            Rectangle {
                Layout.columnSpan: 2
                Layout.fillWidth: true
                Layout.preferredHeight: timeInfo.implicitHeight + 12
                radius: Appearance.rounding.small
                color: Appearance.colors.colLayer1

                RowLayout {
                    id: timeInfo
                    anchors.centerIn: parent
                    spacing: 6

                    MaterialSymbol {
                        fill: 0
                        text: "schedule"
                        iconSize: Appearance.font.pixelSize.normal
                    }

                    StyledText {
                        text: Qt.locale().toString(currentDate, "hh:mm:ss")
                        font.pixelSize: Appearance.font.pixelSize.large
                        color: Appearance.colors.colOnLayer1
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: dayOfYearInfo.implicitHeight + 12
                radius: Appearance.rounding.small
                color: Appearance.colors.colLayer1

                ColumnLayout {
                    id: dayOfYearInfo
                    anchors.centerIn: parent
                    spacing: 2

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        MaterialSymbol {
                            fill: 0
                            text: "counter_1"
                            iconSize: Appearance.font.pixelSize.normal
                        }
                        StyledText {
                            text: "Day of Year"
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: Appearance.colors.colOnLayer1
                        }
                    }
                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: dayOfYear
                        font.pixelSize: Appearance.font.pixelSize.normal
                        color: Appearance.colors.colOnLayer1
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: weekInfo.implicitHeight + 12
                radius: Appearance.rounding.small
                color: Appearance.colors.colLayer1

                ColumnLayout {
                    id: weekInfo
                    anchors.centerIn: parent
                    spacing: 2

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        MaterialSymbol {
                            fill: 0
                            text: "date_range"
                            iconSize: Appearance.font.pixelSize.normal
                        }
                        StyledText {
                            text: "Week"
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: Appearance.colors.colOnLayer1
                        }
                    }
                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: weekNumber
                        font.pixelSize: Appearance.font.pixelSize.normal
                        color: Appearance.colors.colOnLayer1
                    }
                }
            }

            Rectangle {
                Layout.columnSpan: 2
                Layout.fillWidth: true
                Layout.preferredHeight: uptimeInfo.implicitHeight + 12
                radius: Appearance.rounding.small
                color: Appearance.colors.colLayer1

                RowLayout {
                    id: uptimeInfo
                    anchors.centerIn: parent
                    spacing: 6

                    MaterialSymbol {
                        fill: 0
                        text: "timer"
                        iconSize: Appearance.font.pixelSize.normal
                    }

                    StyledText {
                        text: "Uptime:"
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        color: Appearance.colors.colOnLayer1
                    }

                    StyledText {
                        text: DateTime.uptime
                        font.pixelSize: Appearance.font.pixelSize.normal
                        color: Appearance.colors.colOnLayer1
                    }
                }
            }
        }
    }
}
