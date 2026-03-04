import "./weather"
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.UPower
import Qt5Compat.GraphicalEffects
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions

Scope {
    id: bar

    readonly property int osdHideMouseMoveThreshold: 20
    property bool showBarBackground: Config.options.bar.showBackground

    component VerticalBarSeparator: Rectangle {
        Layout.topMargin: Appearance.sizes.baseBarHeight / 3
        Layout.bottomMargin: Appearance.sizes.baseBarHeight / 3
        Layout.fillHeight: true
        implicitWidth: 1
        color: Appearance.colors.colOutlineVariant
    }

    Variants {
        model: {
            const screens = Quickshell.screens;
            const list = Config.options.bar.screenList;
            if (!list || list.length === 0)
                return screens;
            return screens.filter(screen => list.includes(screen.name));
        }
        LazyLoader {
            id: barLoader
            active: GlobalStates.barOpen && !GlobalStates.screenLocked
            required property ShellScreen modelData
            component: PanelWindow {
                id: barRoot
                screen: barLoader.modelData

                property var brightnessMonitor: Brightness.getMonitorForScreen(barLoader.modelData)
                property real useShortenedForm: (Appearance.sizes.barHellaShortenScreenWidthThreshold >= screen.width) ? 2 : (Appearance.sizes.barShortenScreenWidthThreshold >= screen.width) ? 1 : 0
                readonly property int centerSideModuleWidth: (useShortenedForm == 2) ? Appearance.sizes.barCenterSideModuleWidthHellaShortened : (useShortenedForm == 1) ? Appearance.sizes.barCenterSideModuleWidthShortened : Appearance.sizes.barCenterSideModuleWidth

                exclusionMode: ExclusionMode.Ignore
                exclusiveZone: Appearance.sizes.baseBarHeight + (Config.options.bar.cornerStyle === 1 ? Appearance.sizes.hyprlandGapsOut : 0)
                WlrLayershell.namespace: "quickshell:bar"
                implicitHeight: Appearance.sizes.barHeight + Appearance.rounding.screenRounding
                mask: Region {
                    item: barContent
                }
                color: "transparent"

                anchors {
                    top: !Config.options.bar.bottom
                    bottom: Config.options.bar.bottom
                    left: true
                    right: true
                }

                Item {
                    id: barContent
                    anchors {
                        right: parent.right
                        left: parent.left
                        top: parent.top
                        bottom: undefined
                    }
                    implicitHeight: Appearance.sizes.barHeight
                    height: Appearance.sizes.barHeight

                    states: State {
                        name: "bottom"
                        when: Config.options.bar.bottom
                        AnchorChanges {
                            target: barContent
                            anchors {
                                right: parent.right
                                left: parent.left
                                top: undefined
                                bottom: parent.bottom
                            }
                        }
                    }

                    Loader {
                        active: showBarBackground && Config.options.bar.cornerStyle === 1
                        anchors.fill: barBackground
                        sourceComponent: StyledRectangularShadow {
                            anchors.fill: undefined
                            target: barBackground
                        }
                    }
                    Rectangle {
                        id: barBackground
                        anchors {
                            fill: parent
                            topMargin: Config.options.bar.cornerStyle === 1 ? (Appearance.sizes.hyprlandGapsOut) : 0
                            bottomMargin: Config.options.bar.cornerStyle === 1 ? (Appearance.sizes.hyprlandGapsOut) : 0
                            leftMargin: Config.options.bar.cornerStyle === 1 ? (Appearance.sizes.hyprlandGapsOut + 5) : 0
                            rightMargin: Config.options.bar.cornerStyle === 1 ? (Appearance.sizes.hyprlandGapsOut + 5) : 0
                        }
                        color: showBarBackground ? Appearance.colors.colLayer0 : "transparent"
                        radius: Config.options.bar.cornerStyle === 1 ? Appearance.rounding.windowRounding : 0
                        border.width: Config.options.bar.cornerStyle === 1 ? 1 : 0
                        border.color: Appearance.m3colors.m3outlineVariant
                    }

                    MouseArea {
                        id: barLeftCornerMouseArea
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        implicitHeight: Appearance.sizes.baseBarHeight
                        height: Appearance.sizes.barHeight
                        width: 50
                        property bool hovered: false
                        property real lastScrollX: 0
                        property real lastScrollY: 0
                        property bool trackingScroll: false
                        acceptedButtons: Qt.NoButton
                        hoverEnabled: true
                        propagateComposedEvents: true

                        onEntered: event => {
                            barLeftCornerMouseArea.hovered = true;
                        }
                        onExited: event => {
                            barLeftCornerMouseArea.hovered = false;
                            barLeftCornerMouseArea.trackingScroll = false;
                        }

                        WheelHandler {
                            onWheel: event => {
                                if (event.angleDelta.y < 0)
                                    barRoot.brightnessMonitor.setBrightness(barRoot.brightnessMonitor.brightness - 0.05);
                                else if (event.angleDelta.y > 0)
                                    barRoot.brightnessMonitor.setBrightness(barRoot.brightnessMonitor.brightness + 0.05);
                                barLeftCornerMouseArea.lastScrollX = event.x;
                                barLeftCornerMouseArea.lastScrollY = event.y;
                                barLeftCornerMouseArea.trackingScroll = true;
                            }
                            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                        }

                        onPositionChanged: mouse => {
                            if (barLeftCornerMouseArea.trackingScroll) {
                                const dx = mouse.x - barLeftCornerMouseArea.lastScrollX;
                                const dy = mouse.y - barLeftCornerMouseArea.lastScrollY;
                                if (Math.sqrt(dx * dx + dy * dy) > osdHideMouseMoveThreshold) {
                                    Hyprland.dispatch('global quickshell:osdBrightnessHide');
                                    barLeftCornerMouseArea.trackingScroll = false;
                                }
                            }
                        }

                        ScrollHint {
                            reveal: barLeftCornerMouseArea.hovered
                            icon: "light_mode"
                            tooltipText: Translation.tr("Scroll to change brightness")
                            side: "left"
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Item {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        implicitHeight: leftSectionRowLayout.implicitHeight
                        implicitWidth: leftSectionRowLayout.implicitWidth
                        height: Appearance.sizes.barHeight

                        RowLayout {
                            id: leftSectionRowLayout
                            anchors.fill: parent
                            spacing: 10

                            RippleButton {
                                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                Layout.leftMargin: Appearance.rounding.screenRounding
                                Layout.fillWidth: false
                                property real buttonPadding: 5
                                implicitWidth: distroIcon.width + buttonPadding * 2
                                implicitHeight: distroIcon.height + buttonPadding * 2
                                enabled: false

                                buttonRadius: Appearance.rounding.full
                                colBackground: ColorUtils.transparentize(Appearance.colors.colLayer1Hover, 1)
                                colBackgroundHover: ColorUtils.transparentize(Appearance.colors.colLayer1Hover, 1)
                                colRipple: ColorUtils.transparentize(Appearance.colors.colLayer1Active, 1)
                                property color colText: ColorUtils.transparentize(Appearance.colors.colOnLayer0, 0.5)

                                Item {
                                    implicitWidth: distroIcon.width
                                    implicitHeight: distroIcon.height
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.verticalCenterOffset: 3
                                    CustomIcon {
                                        id: distroIcon
                                        width: 19.5
                                        height: 19.5
                                        source: SystemInfo.distroIcon
                                    }
                                    ColorOverlay {
                                        anchors.fill: distroIcon
                                        source: distroIcon
                                        color: Appearance.colors.colOnLayer0
                                    }
                                }
                            }

                            ActiveWindow {
                                visible: barRoot.useShortenedForm === 0
                                Layout.rightMargin: Appearance.rounding.screenRounding
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                bar: barRoot
                            }
                        }
                    }

                    BarGroup {
                        id: workspacesGroup
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.horizontalCenterOffset: -parent.width * 0.30
                        anchors.verticalCenter: parent.verticalCenter
                        height: parent.height
                        padding: workspacesWidget.widgetPadding

                        Workspaces {
                            id: workspacesWidget
                            bar: barRoot
                            Layout.alignment: Qt.AlignVCenter
                            MouseArea {
                                anchors.fill: parent
                                acceptedButtons: Qt.RightButton
                                onPressed: event => {
                                    if (event.button === Qt.RightButton) {
                                        Hyprland.dispatch('global quickshell:overviewToggle');
                                    }
                                }
                            }
                        }
                    }

                    Item {
                        id: middleSection
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width * 0.6
                        height: parent.height
                    }

                    BarGroup {
                        id: menuGroup
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.horizontalCenterOffset: parent.width * 0.15
                        anchors.verticalCenter: parent.verticalCenter
                        height: parent.height
                        padding: 8

                        UtilButtons {
                            Layout.alignment: Qt.AlignVCenter
                            visible: (Config.options.bar.verbose && barRoot.useShortenedForm === 0)
                        }
                    }

                    BarGroup {
                        id: weatherGroup
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.horizontalCenterOffset: -parent.width * 0.15
                        anchors.verticalCenter: parent.verticalCenter
                        height: parent.height

                        Loader {
                            id: weatherLoader
                            Layout.alignment: Qt.AlignVCenter
                            active: Config.options.bar.weather.enable
                            sourceComponent: WeatherBar {}
                        }
                    }

                    BarGroup {
                        id: centerGroup
                        anchors.centerIn: parent
                        height: parent.height

                        ClockWidget {
                            id: clockWidget
                            Layout.alignment: Qt.AlignVCenter
                            showDate: true
                        }
                    }

                    BarGroup {
                        id: resourcesGroup
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.horizontalCenterOffset: parent.width * 0.32
                        anchors.verticalCenter: parent.verticalCenter
                        height: parent.height

                        Resources {
                            Layout.alignment: Qt.AlignVCenter
                            Layout.fillHeight: true
                        }
                    }

                    MouseArea {
                        id: barRightCornerMouseArea
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        implicitHeight: Appearance.sizes.baseBarHeight
                        height: Appearance.sizes.barHeight
                        width: 50

                        property bool hovered: false
                        property real lastScrollX: 0
                        property real lastScrollY: 0
                        property bool trackingScroll: false

                        acceptedButtons: Qt.NoButton
                        hoverEnabled: true
                        propagateComposedEvents: true

                        onEntered: event => {
                            barRightCornerMouseArea.hovered = true;
                        }
                        onExited: event => {
                            barRightCornerMouseArea.hovered = false;
                            barRightCornerMouseArea.trackingScroll = false;
                        }

                        WheelHandler {
                            onWheel: event => {
                                const currentVolume = Audio.value;
                                const step = currentVolume < 0.1 ? 0.01 : 0.02 || 0.2;
                                if (event.angleDelta.y < 0)
                                    Audio.sink.audio.volume -= step;
                                else if (event.angleDelta.y > 0)
                                    Audio.sink.audio.volume = Math.min(1, Audio.sink.audio.volume + step);
                                barRightCornerMouseArea.lastScrollX = event.x;
                                barRightCornerMouseArea.lastScrollY = event.y;
                                barRightCornerMouseArea.trackingScroll = true;
                            }
                            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                        }

                        onPositionChanged: mouse => {
                            if (barRightCornerMouseArea.trackingScroll) {
                                const dx = mouse.x - barRightCornerMouseArea.lastScrollX;
                                const dy = mouse.y - barRightCornerMouseArea.lastScrollY;
                                if (Math.sqrt(dx * dx + dy * dy) > osdHideMouseMoveThreshold) {
                                    Hyprland.dispatch('global quickshell:osdVolumeHide');
                                    barRightCornerMouseArea.trackingScroll = false;
                                }
                            }
                        }

                        ScrollHint {
                            reveal: barRightCornerMouseArea.hovered
                            icon: "volume_up"
                            tooltipText: Translation.tr("Scroll to change volume")
                            side: "right"
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Item {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        implicitHeight: rightSectionRowLayout.implicitHeight
                        implicitWidth: rightSectionRowLayout.implicitWidth
                        height: Appearance.sizes.barHeight

                        RowLayout {
                            id: rightSectionRowLayout
                            anchors.fill: parent
                            spacing: 5
                            layoutDirection: Qt.RightToLeft

                            RippleButton {
                                    id: rightSidebarButton

                                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                    Layout.rightMargin: Appearance.rounding.screenRounding
                                    Layout.fillWidth: false

                                    implicitWidth: indicatorsRowLayout.implicitWidth + 10 * 2
                                    implicitHeight: indicatorsRowLayout.implicitHeight + 5 * 2

                                    buttonRadius: Appearance.rounding.full
                                    colBackground: barRightCornerMouseArea.hovered ? Appearance.colors.colLayer1Hover : ColorUtils.transparentize(Appearance.colors.colLayer1Hover, 1)
                                    colBackgroundHover: Appearance.colors.colLayer1Hover
                                    colRipple: Appearance.colors.colLayer1Active
                                    colBackgroundToggled: Appearance.colors.colSecondaryContainer
                                    colBackgroundToggledHover: Appearance.colors.colSecondaryContainerHover
                                    colRippleToggled: Appearance.colors.colSecondaryContainerActive
                                    toggled: GlobalStates.sidebarRightOpen
                                    property color colText: toggled ? Appearance.m3colors.m3onSecondaryContainer : Appearance.colors.colOnLayer0

                                    Behavior on colText {
                                        animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
                                    }

                                    onPressed: {
                                        Hyprland.dispatch('global quickshell:sidebarRightToggle');
                                    }

                                    RowLayout {
                                        id: indicatorsRowLayout
                                        anchors.centerIn: parent
                                        property real realSpacing: 15
                                        spacing: 0

                                        Revealer {
                                            reveal: Audio.sink?.audio?.muted ?? false
                                            Layout.fillHeight: true
                                            Layout.rightMargin: reveal ? indicatorsRowLayout.realSpacing : 0
                                            Behavior on Layout.rightMargin {
                                                NumberAnimation {
                                                    duration: Appearance.animation.elementMoveFast.duration
                                                    easing.type: Appearance.animation.elementMoveFast.type
                                                    easing.bezierCurve: Appearance.animation.elementMoveFast.bezierCurve
                                                }
                                            }
                                            MaterialSymbol {
                                                text: "volume_off"
                                                iconSize: Appearance.font.pixelSize.larger
                                                color: rightSidebarButton.colText
                                            }
                                        }
                                        Revealer {
                                            reveal: Audio.source?.audio?.muted ?? false
                                            Layout.fillHeight: true
                                            Layout.rightMargin: reveal ? indicatorsRowLayout.realSpacing : 0
                                            Behavior on Layout.rightMargin {
                                                NumberAnimation {
                                                    duration: Appearance.animation.elementMoveFast.duration
                                                    easing.type: Appearance.animation.elementMoveFast.type
                                                    easing.bezierCurve: Appearance.animation.elementMoveFast.bezierCurve
                                                }
                                            }
                                            MaterialSymbol {
                                                text: "mic_off"
                                                iconSize: Appearance.font.pixelSize.larger
                                                color: rightSidebarButton.colText
                                            }
                                        }
                                        MaterialSymbol {
                                            Layout.rightMargin: indicatorsRowLayout.realSpacing
                                            text: Network.materialSymbol
                                            iconSize: Appearance.font.pixelSize.larger
                                            color: rightSidebarButton.colText
                                        }
                                        MaterialSymbol {
                                            text: BluetoothStatus.connected ? "bluetooth_connected" : BluetoothStatus.enabled ? "bluetooth" : "bluetooth_disabled"
                                            iconSize: Appearance.font.pixelSize.larger
                                            color: rightSidebarButton.colText
                                        }
                                        BatteryIndicator {
                                            visible: UPower.displayDevice.isLaptopBattery
                                            Layout.alignment: Qt.AlignVCenter
                                        }
                                    }
                                }

                                SysTray {
                                    bar: barRoot
                                    visible: barRoot.useShortenedForm === 0
                                    Layout.fillWidth: false
                                    Layout.fillHeight: true
                                }


                                Item {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                }

                            }
                        }
                    }

                Loader {
                    id: roundDecorators
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    y: Appearance.sizes.barHeight
                    width: parent.width
                    height: Appearance.rounding.screenRounding
                    active: showBarBackground && Config.options.bar.cornerStyle === 0

                    states: State {
                        name: "bottom"
                        when: Config.options.bar.bottom
                        PropertyChanges {
                            roundDecorators.y: 0
                        }
                    }

                    sourceComponent: Item {
                        implicitHeight: Appearance.rounding.screenRounding
                        RoundCorner {
                            id: leftCorner
                            anchors {
                                top: parent.top
                                bottom: parent.bottom
                                left: parent.left
                            }

                            implicitSize: Appearance.rounding.screenRounding
                            color: showBarBackground ? Appearance.colors.colLayer0 : "transparent"

                            corner: RoundCorner.CornerEnum.TopLeft
                            states: State {
                                name: "bottom"
                                when: Config.options.bar.bottom
                                PropertyChanges {
                                    leftCorner.corner: RoundCorner.CornerEnum.BottomLeft
                                }
                            }
                        }
                        RoundCorner {
                            id: rightCorner
                            anchors {
                                right: parent.right
                                top: !Config.options.bar.bottom ? parent.top : undefined
                                bottom: Config.options.bar.bottom ? parent.bottom : undefined
                            }
                            implicitSize: Appearance.rounding.screenRounding
                            color: showBarBackground ? Appearance.colors.colLayer0 : "transparent"

                            corner: RoundCorner.CornerEnum.TopRight
                            states: State {
                                name: "bottom"
                                when: Config.options.bar.bottom
                                PropertyChanges {
                                    rightCorner.corner: RoundCorner.CornerEnum.BottomRight
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    IpcHandler {
        target: "bar"

        function toggle(): void {
            GlobalStates.barOpen = !GlobalStates.barOpen
        }

        function close(): void {
            GlobalStates.barOpen = false
        }

        function open(): void {
            GlobalStates.barOpen = true
        }
    }

    GlobalShortcut {
        name: "barToggle"
        description: "Toggles bar on press"

        onPressed: {
            GlobalStates.barOpen = !GlobalStates.barOpen;
        }
    }

    GlobalShortcut {
        name: "barOpen"
        description: "Opens bar on press"

        onPressed: {
            GlobalStates.barOpen = true;
        }
    }

    GlobalShortcut {
        name: "barClose"
        description: "Closes bar on press"

        onPressed: {
            GlobalStates.barOpen = false;
        }
    }
}
