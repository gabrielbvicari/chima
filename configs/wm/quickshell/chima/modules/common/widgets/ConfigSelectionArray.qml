import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions

Item {
    id: root
    Layout.fillWidth: true
    property list<var> options: []
    property string configOptionName: ""
    property var currentValue: null
    property bool justified: false

    implicitHeight: justified ? rowLayout.implicitHeight : flowLayout.implicitHeight
    implicitWidth: justified ? rowLayout.implicitWidth : flowLayout.implicitWidth

    signal selected(var newValue)

    Flow {
        id: flowLayout
        visible: !root.justified
        anchors.fill: parent
        spacing: 2

        Repeater {
            model: root.options
            delegate: SelectionGroupButton {
                id: paletteButton
                required property var modelData
                required property int index
                onYChanged: {
                    if (index === 0) {
                        paletteButton.leftmost = true
                    } else {
                        var prev = flowLayout.children[index - 1]
                        var thisIsOnNewLine = prev && prev.y !== paletteButton.y
                        paletteButton.leftmost = thisIsOnNewLine
                        prev.rightmost = thisIsOnNewLine
                    }
                }
                leftmost: index === 0
                rightmost: index === root.options.length - 1
                buttonText: modelData.displayName;
                toggled: root.currentValue === modelData.value
                onClicked: {
                    root.selected(modelData.value);
                }
            }
        }
    }

    Grid {
        id: rowLayout
        visible: root.justified
        anchors.fill: parent
        spacing: 2
        columns: Math.min(root.options.length, 3)

        Repeater {
            model: root.options
            delegate: SelectionGroupButton {
                required property var modelData
                required property int index
                width: (rowLayout.width - (rowLayout.columns - 1) * rowLayout.spacing) / rowLayout.columns
                leftmost: (index % rowLayout.columns) === 0
                rightmost: (index % rowLayout.columns) === (rowLayout.columns - 1) || index === root.options.length - 1
                buttonText: modelData.displayName;
                toggled: root.currentValue === modelData.value
                onClicked: {
                    root.selected(modelData.value);
                }
            }
        }
    }
}
