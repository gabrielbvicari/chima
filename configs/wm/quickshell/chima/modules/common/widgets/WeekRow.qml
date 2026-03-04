import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.services
import qs.modules.common.functions

RowLayout {
    id: root

    required property date date
    property var locale

    property list<var> model: {
        const firstDayOfWeek = DateUtils.getFirstDayOfWeek(root.date, root.locale.firstDayOfWeek);
        const weekDates = [];
        for (let i = 0; i < 7; i++) {
            const dayDate = new Date(firstDayOfWeek);
            dayDate.setDate(firstDayOfWeek.getDate() + i);
            weekDates.push({ 
                date: dayDate,
                day: dayDate.getDate(),
                month: dayDate.getMonth() + 1,
                year: dayDate.getFullYear(),
                today: DateUtils.sameDate(dayDate, DateTime.clock.date)
            });
        }
        return weekDates;
    }
    property Component delegate: Text {
        required property var model
        text: model.day
    }

    Repeater {
        model: root.model
        delegate: root.delegate
    }
}
