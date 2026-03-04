//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

// Adjust this to make the app smaller or larger
//@ pragma Env QT_SCALE_FACTOR=1

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions as CF

ApplicationWindow {
    id: root
    property string firstRunFilePath: CF.FileUtils.trimFileProtocol(`${Directories.state}/user/first_run.txt`)
    property string firstRunFileContent: "This file is just here to confirm you've been greeted :>"
    property real contentPadding: 8
    property bool showNextTime: false
    property string settingsQmlPath: Quickshell.shellPath("settings.qml")
    visible: true
    onClosing: Qt.quit()
    title: Translation.tr("Welcome")

    Component.onCompleted: {
        MaterialThemeLoader.reapplyTheme()
    }

    minimumWidth: 600
    minimumHeight: 400
    width: 800
    height: 650
    color: Appearance.m3colors.m3background


    ColumnLayout {
        anchors {
            fill: parent
            margins: contentPadding
        }

        Item { // Titlebar
            visible: Config.options?.windows.showTitlebar
            Layout.fillWidth: true
            implicitHeight: Math.max(welcomeText.implicitHeight, windowControlsRow.implicitHeight)
            StyledText {
                id: welcomeText
                anchors {
                    left: Config.options.windows.centerTitle ? undefined : parent.left
                    horizontalCenter: Config.options.windows.centerTitle ? parent.horizontalCenter : undefined
                    verticalCenter: parent.verticalCenter
                    leftMargin: 12
                }
                color: Appearance.colors.colOnLayer0
                text: Translation.tr("Welcome")
                font.pixelSize: Appearance.font.pixelSize.title
                font.family: Appearance.font.family.title
            }
            RowLayout { // Window controls row
                id: windowControlsRow
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                StyledText {
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    text: Translation.tr("Show next time")
                }
                StyledSwitch {
                    id: showNextTimeSwitch
                    checked: root.showNextTime
                    scale: 0.6
                    Layout.alignment: Qt.AlignVCenter
                    onCheckedChanged: {
                        if (checked) {
                            Quickshell.execDetached(["rm", root.firstRunFilePath])
                        } else {
                            Quickshell.execDetached(["bash", "-c", `echo '${CF.StringUtils.shellSingleQuoteEscape(root.firstRunFileContent)}' > '${CF.StringUtils.shellSingleQuoteEscape(root.firstRunFilePath)}'`])
                        }
                    }
                }
                RippleButton {
                    buttonRadius: Appearance.rounding.full
                    implicitWidth: 35
                    implicitHeight: 35
                    onClicked: root.close()
                    contentItem: MaterialSymbol {
                        anchors.centerIn: parent
                        horizontalAlignment: Text.AlignHCenter
                        text: "close"
                        iconSize: 20
                    }
                }
            }
        }
        Rectangle { // Content container
            color: Appearance.m3colors.m3surfaceContainerLow
            radius: Appearance.rounding.windowRounding - root.contentPadding
            implicitHeight: contentColumn.implicitHeight
            implicitWidth: contentColumn.implicitWidth
            Layout.fillWidth: true
            Layout.fillHeight: true


            ContentPage {
                id: contentColumn
                anchors.fill: parent

                ContentSection {
                    title: Translation.tr("Style & Wallpaper")

                    // Light/Dark mode preference
                    ButtonGroup {
                        id: lightDarkButtonGroup
                        Layout.fillWidth: true
                        LightDarkPreferenceButton {
                            dark: true
                        }
                        LightDarkPreferenceButton {
                            dark: false
                        }
                    }

                    // Material palette selection
                    ContentSubsection {
                        title: Translation.tr("Material Palette")
                        ConfigSelectionArray {
                            currentValue: Config.options.appearance.palette.type
                            configOptionName: "appearance.palette.type"
                            onSelected: (newValue) => {
                                Config.options.appearance.palette.type = newValue;
                                Quickshell.execDetached(["bash", "-c", `${Directories.wallpaperSwitchScriptPath} --noswitch`])
                            }
                            options: [
                                {"value": "scheme-monochrome", "displayName": Translation.tr("Monochrome")},
                                {"value": "scheme-neutral", "displayName": Translation.tr("Neutral")},
                                {"value": "scheme-content", "displayName": Translation.tr("Content")},
                                {"value": "scheme-expressive", "displayName": Translation.tr("Expressive")},
                                {"value": "scheme-fidelity", "displayName": Translation.tr("Fidelity")},
                                {"value": "scheme-fruit-salad", "displayName": Translation.tr("Fruit Salad")},
                                {"value": "scheme-rainbow", "displayName": Translation.tr("Rainbow")},
                                {"value": "scheme-tonal-spot", "displayName": Translation.tr("Tonal Spot")},
                                {"value": "auto", "displayName": Translation.tr("Auto")}
                            ]
                        }
                    }

                    // Wallpaper selection
                    ContentSubsection {
                        title: Translation.tr("Wallpaper")

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            RippleButtonWithIcon {
                                Layout.fillWidth: true
                                materialIcon: "wallpaper"
                                onClicked: {
                                    Quickshell.execDetached(`${Directories.wallpaperSwitchScriptPath}`)
                                }
                                mainContentComponent: Component {
                                    StyledText {
                                        font.pixelSize: Appearance.font.pixelSize.small
                                        text: Translation.tr("Desktop")
                                        color: Appearance.colors.colOnSecondaryContainer
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                }
                            }

                            RippleButtonWithIcon {
                                Layout.fillWidth: true
                                materialIcon: "lock"
                                onClicked: {
                                    Quickshell.execDetached(`${Directories.scriptPath}/switch-hyprlock-wallpaper.sh`)
                                }
                                mainContentComponent: Component {
                                    StyledText {
                                        font.pixelSize: Appearance.font.pixelSize.small
                                        text: Translation.tr("Hyprlock")
                                        color: Appearance.colors.colOnSecondaryContainer
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                }
                            }
                        }
                    }
                }

                ContentSection {
                    title: Translation.tr("Quick Access")

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        RippleButtonWithIcon {
                            Layout.fillWidth: true
                            materialIcon: "settings"
                            onClicked: {
                                Quickshell.execDetached(["qs", "-p", root.settingsQmlPath])
                            }
                            mainContentComponent: Component {
                                StyledText {
                                    font.pixelSize: Appearance.font.pixelSize.small
                                    text: Translation.tr("Settings")
                                    color: Appearance.colors.colOnSecondaryContainer
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }
                        }

                        RippleButtonWithIcon {
                            Layout.fillWidth: true
                            materialIcon: "keyboard_alt"
                            onClicked: {
                                Hyprland.dispatch("global quickshell:cheatsheetOpen")
                            }
                            mainContentComponent: Component {
                                StyledText {
                                    font.pixelSize: Appearance.font.pixelSize.small
                                    text: Translation.tr("Keybinds")
                                    color: Appearance.colors.colOnSecondaryContainer
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }
                        }
                    }
                }

                ContentSection {
                    title: Translation.tr("Essential Keybinds")

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: keybindsGrid1.implicitHeight + 20
                            color: "transparent"
                            radius: Appearance.rounding.normal

                            GridLayout {
                                id: keybindsGrid1
                                anchors.centerIn: parent
                                width: parent.width - 20
                                columns: 2
                                columnSpacing: 10
                                rowSpacing: 12

                                // Launcher
                                RowLayout {
                                    spacing: 4
                                    KeyboardKey { key: "󰖳" }
                                }
                                StyledText {
                                    Layout.fillWidth: true
                                    font.pixelSize: Appearance.font.pixelSize.small
                                    horizontalAlignment: Text.AlignRight
                                    text: Translation.tr("Launcher")
                                }

                                // Cheatsheet
                                RowLayout {
                                    spacing: 4
                                    KeyboardKey { key: "󰖳" }
                                    StyledText {
                                        Layout.alignment: Qt.AlignVCenter
                                        text: "+"
                                    }
                                    KeyboardKey { key: "." }
                                }
                                StyledText {
                                    Layout.fillWidth: true
                                    font.pixelSize: Appearance.font.pixelSize.small
                                    horizontalAlignment: Text.AlignRight
                                    text: Translation.tr("Cheatsheet")
                                }

                                // Terminal
                                RowLayout {
                                    spacing: 4
                                    KeyboardKey { key: "󰖳" }
                                    StyledText {
                                        Layout.alignment: Qt.AlignVCenter
                                        text: "+"
                                    }
                                    KeyboardKey { key: "Enter" }
                                }
                                StyledText {
                                    Layout.fillWidth: true
                                    font.pixelSize: Appearance.font.pixelSize.small
                                    horizontalAlignment: Text.AlignRight
                                    text: Translation.tr("Terminal")
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: keybindsGrid2.implicitHeight + 20
                            color: "transparent"
                            radius: Appearance.rounding.normal

                            GridLayout {
                                id: keybindsGrid2
                                anchors.centerIn: parent
                                width: parent.width - 20
                                columns: 2
                                columnSpacing: 10
                                rowSpacing: 12

                                // Browser (Zen)
                                RowLayout {
                                    spacing: 4
                                    KeyboardKey { key: "󰖳" }
                                    StyledText {
                                        Layout.alignment: Qt.AlignVCenter
                                        text: "+"
                                    }
                                    KeyboardKey { key: "Z" }
                                }
                                StyledText {
                                    Layout.fillWidth: true
                                    font.pixelSize: Appearance.font.pixelSize.small
                                    horizontalAlignment: Text.AlignRight
                                    text: Translation.tr("Browser")
                                }

                                // Settings
                                RowLayout {
                                    spacing: 4
                                    KeyboardKey { key: "󰖳" }
                                    StyledText {
                                        Layout.alignment: Qt.AlignVCenter
                                        text: "+"
                                    }
                                    KeyboardKey { key: "I" }
                                }
                                StyledText {
                                    Layout.fillWidth: true
                                    font.pixelSize: Appearance.font.pixelSize.small
                                    horizontalAlignment: Text.AlignRight
                                    text: Translation.tr("Settings")
                                }

                                // Session menu
                                RowLayout {
                                    spacing: 4
                                    KeyboardKey { key: "Ctrl" }
                                    StyledText {
                                        Layout.alignment: Qt.AlignVCenter
                                        text: "+"
                                    }
                                    KeyboardKey { key: "Alt" }
                                    StyledText {
                                        Layout.alignment: Qt.AlignVCenter
                                        text: "+"
                                    }
                                    KeyboardKey { key: "Del" }
                                }
                                StyledText {
                                    Layout.fillWidth: true
                                    font.pixelSize: Appearance.font.pixelSize.small
                                    horizontalAlignment: Text.AlignRight
                                    text: Translation.tr("Session")
                                }
                            }
                        }
                    }
                }

                ContentSection {
                    title: Translation.tr("System")

                    Item {
                        Layout.fillWidth: true
                        implicitHeight: systemRow.implicitHeight

                        RowLayout {
                            id: systemRow
                            anchors.centerIn: parent
                            spacing: 20
                            IconImage {
                                implicitSize: 60
                                source: Quickshell.iconPath(SystemInfo.logo)
                            }
                            ColumnLayout {
                                Layout.alignment: Qt.AlignVCenter
                                StyledText {
                                    text: SystemInfo.distroName
                                    font.pixelSize: Appearance.font.pixelSize.large
                                }
                                StyledText {
                                    font.pixelSize: Appearance.font.pixelSize.small
                                    text: SystemInfo.homeUrl
                                    textFormat: Text.MarkdownText
                                    onLinkActivated: (link) => {
                                        Qt.openUrlExternally(link)
                                    }
                                    PointingHandLinkHover {}
                                }
                            }
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
            }
        }
    }

    component KeybindRow: RowLayout {
        property string keybind: ""
        property string description: ""

        Layout.fillWidth: true
        spacing: 15

        StyledText {
            Layout.preferredWidth: 150
            text: keybind
            font.pixelSize: Appearance.font.pixelSize.small
            font.family: "monospace"
            color: Appearance.colors.colPrimary
        }

        StyledText {
            Layout.fillWidth: true
            text: description
            font.pixelSize: Appearance.font.pixelSize.small
            color: Appearance.colors.colOnLayer0
        }
    }
}
