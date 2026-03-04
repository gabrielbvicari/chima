import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions

ContentPage {
    baseWidth: lightDarkButtonGroup.implicitWidth
    forceWidth: true

    ContentSection {
        title: Translation.tr("Colors & Wallpaper")

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

        // Color generation from wallpaper
        ContentSubsection {
            title: Translation.tr("Color Generation")

            ConfigRow {
                uniform: true
                ConfigSwitch {
                    text: Translation.tr("Shell & Utilities")
                    checked: Config.options.appearance.wallpaperTheming.enableAppsAndShell
                    onCheckedChanged: {
                        Config.options.appearance.wallpaperTheming.enableAppsAndShell = checked;
                    }
                }
                ConfigSwitch {
                    text: Translation.tr("QT Apps")
                    checked: Config.options.appearance.wallpaperTheming.enableQtApps
                    onCheckedChanged: {
                        Config.options.appearance.wallpaperTheming.enableQtApps = checked;
                    }
                    StyledToolTip {
                        text: Translation.tr("Shell & Utilities theming must also be enabled")
                    }
                }
                ConfigSwitch {
                    text: Translation.tr("Terminal")
                    checked: Config.options.appearance.wallpaperTheming.enableTerminal
                    onCheckedChanged: {
                        Config.options.appearance.wallpaperTheming.enableTerminal = checked;
                    }
                    StyledToolTip {
                        text: Translation.tr("Shell & Utilities theming must also be enabled")
                    }
                }
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
        title: Translation.tr("Decorations & Effects")

        ContentSubsection {
            title: Translation.tr("Screen Rounding")

            ConfigSelectionArray {
                currentValue: Config.options.appearance.fakeScreenRounding
                configOptionName: "appearance.fakeScreenRounding"
                onSelected: (newValue) => {
                    Config.options.appearance.fakeScreenRounding = newValue;
                }
                options: [
                    {"value": 0, "displayName": Translation.tr("No")},
                    {"value": 1, "displayName": Translation.tr("Yes")},
                    {"value": 2, "displayName": Translation.tr("When Not Fullscreen")}
                ]
            }
        }

        ContentSubsection {
            title: Translation.tr("Transparency")

            ConfigRow {
                ConfigSwitch {
                    text: Translation.tr("Enable")
                    checked: Config.options.appearance.transparency
                    onCheckedChanged: {
                        Config.options.appearance.transparency = checked;
                    }
                }
            }
        }

        ContentSubsection {
            title: Translation.tr("Shell Windows")

            ConfigRow {
                uniform: true
                ConfigSwitch {
                    text: Translation.tr("Title bar")
                    checked: Config.options.windows.showTitlebar
                    onCheckedChanged: {
                        Config.options.windows.showTitlebar = checked;
                    }
                }
                ConfigSwitch {
                    text: Translation.tr("Center title")
                    checked: Config.options.windows.centerTitle
                    onCheckedChanged: {
                        Config.options.windows.centerTitle = checked;
                    }
                }
            }
        }

        ContentSubsection {
            title: Translation.tr("Wallpaper Parallax")

            ConfigRow {
                uniform: true
                ConfigSwitch {
                    text: Translation.tr("Depends on workspace")
                    checked: Config.options.background.parallax.enableWorkspace
                    onCheckedChanged: {
                        Config.options.background.parallax.enableWorkspace = checked;
                    }
                }
                ConfigSwitch {
                    text: Translation.tr("Depends on sidebars")
                    checked: Config.options.background.parallax.enableSidebar
                    onCheckedChanged: {
                        Config.options.background.parallax.enableSidebar = checked;
                    }
                }
            }
            ConfigSpinBox {
                text: Translation.tr("Preferred wallpaper zoom (%)")
                value: Config.options.background.parallax.workspaceZoom * 100
                from: 100
                to: 150
                stepSize: 1
                onValueChanged: {
                    console.log(value/100)
                    Config.options.background.parallax.workspaceZoom = value / 100;
                }
            }
        }
    }
}