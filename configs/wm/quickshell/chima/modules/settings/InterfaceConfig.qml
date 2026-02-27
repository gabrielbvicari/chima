import QtQuick
import QtQuick.Layouts
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets

ContentPage {
    forceWidth: true

    ContentSection {
        title: Translation.tr("Bar")

        ConfigSelectionArray {
            justified: true
            currentValue: Config.options.bar.cornerStyle
            configOptionName: "bar.cornerStyle"
            onSelected: newValue => {
                Config.options.bar.cornerStyle = newValue;
            }
            options: [
                {
                    displayName: Translation.tr("Hug"),
                    value: 0
                },
                {
                    displayName: Translation.tr("Float"),
                    value: 1
                },
                {
                    displayName: Translation.tr("Rectangle"),
                    value: 2
                }
            ]
        }

        ContentSubsection {
            title: Translation.tr("Appearance")
            ConfigRow {
                uniform: true
                ConfigSwitch {
                    text: Translation.tr('Show border')
                    checked: !Config.options.bar.borderless
                    onCheckedChanged: {
                        Config.options.bar.borderless = !checked;
                    }
                }
                ConfigSwitch {
                    text: Translation.tr('Show background')
                    checked: Config.options.bar.showBackground
                    onCheckedChanged: {
                        Config.options.bar.showBackground = checked;
                    }
                }
            }
        }

        ContentSubsection {
            title: Translation.tr("Buttons")
            ConfigRow {
                uniform: true
                ConfigSwitch {
                    text: Translation.tr("Screen snip")
                    checked: Config.options.bar.utilButtons.showScreenSnip
                    onCheckedChanged: {
                        Config.options.bar.utilButtons.showScreenSnip = checked;
                    }
                }
                ConfigSwitch {
                    text: Translation.tr("Color picker")
                    checked: Config.options.bar.utilButtons.showColorPicker
                    onCheckedChanged: {
                        Config.options.bar.utilButtons.showColorPicker = checked;
                    }
                }
            }
            ConfigRow {
                uniform: true
                ConfigSwitch {
                    text: Translation.tr("Microphone toggle")
                    checked: Config.options.bar.utilButtons.showMicToggle
                    onCheckedChanged: {
                        Config.options.bar.utilButtons.showMicToggle = checked;
                    }
                }
                ConfigSwitch {
                    text: Translation.tr("Keyboard toggle")
                    checked: Config.options.bar.utilButtons.showKeyboardToggle
                    onCheckedChanged: {
                        Config.options.bar.utilButtons.showKeyboardToggle = checked;
                    }
                }
            }
            ConfigRow {
                uniform: true
                ConfigSwitch {
                    text: Translation.tr("Theme toggle")
                    checked: Config.options.bar.utilButtons.showDarkModeToggle
                    onCheckedChanged: {
                        Config.options.bar.utilButtons.showDarkModeToggle = checked;
                    }
                }
                ConfigSwitch {
                    opacity: 0
                    enabled: false
                }
            }
        }

        ContentSubsection {
            title: Translation.tr("Workspaces")

            ConfigRow {
                uniform: true
                ConfigSwitch {
                    text: Translation.tr('Show application icons')
                    checked: Config.options.bar.workspaces.showAppIcons
                    onCheckedChanged: {
                        Config.options.bar.workspaces.showAppIcons = checked;
                    }
                }
                ConfigSwitch {
                    text: Translation.tr('Always show numbers')
                    checked: Config.options.bar.workspaces.alwaysShowNumbers
                    onCheckedChanged: {
                        Config.options.bar.workspaces.alwaysShowNumbers = checked;
                    }
                }
            }
            ConfigSpinBox {
                text: Translation.tr("Workspaces shown")
                value: Config.options.bar.workspaces.shown
                from: 1
                to: 30
                stepSize: 1
                onValueChanged: {
                    Config.options.bar.workspaces.shown = value;
                }
            }
            ConfigSpinBox {
                text: Translation.tr("Number show delay when pressing Super (ms)")
                value: Config.options.bar.workspaces.showNumberDelay
                from: 0
                to: 1000
                stepSize: 50
                onValueChanged: {
                    Config.options.bar.workspaces.showNumberDelay = value;
                }
            }
        }

        ContentSubsection {
            title: Translation.tr("Weather")
            ConfigSwitch {
                text: Translation.tr("Enable")
                checked: Config.options.bar.weather.enable
                onCheckedChanged: {
                    Config.options.bar.weather.enable = checked;
                }
            }
        }
    }

    ContentSection {
        title: Translation.tr("Dock")

        ConfigSwitch {
            text: Translation.tr("Enable")
            checked: Config.options.dock.enable
            onCheckedChanged: {
                Config.options.dock.enable = checked;
            }
        }

        ConfigRow {
            uniform: true
            ConfigSwitch {
                text: Translation.tr("Hover to reveal")
                checked: Config.options.dock.hoverToReveal
                onCheckedChanged: {
                    Config.options.dock.hoverToReveal = checked;
                }
            }
            ConfigSwitch {
                text: Translation.tr("Pinned on startup")
                checked: Config.options.dock.pinnedOnStartup
                onCheckedChanged: {
                    Config.options.dock.pinnedOnStartup = checked;
                }
            }
        }
    }

    ContentSection {
        title: Translation.tr("On-Screen Display")
        ConfigSpinBox {
            text: Translation.tr("Timeout (ms)")
            value: Config.options.osd.timeout
            from: 100
            to: 3000
            stepSize: 100
            onValueChanged: {
                Config.options.osd.timeout = value;
            }
        }
    }

    ContentSection {
        title: Translation.tr("Overview")
        ConfigSpinBox {
            text: Translation.tr("Scale (%)")
            value: Config.options.overview.scale * 100
            from: 1
            to: 100
            stepSize: 1
            onValueChanged: {
                Config.options.overview.scale = value / 100;
            }
        }
        ConfigRow {
            uniform: true
            ConfigSpinBox {
                text: Translation.tr("Rows")
                value: Config.options.overview.rows
                from: 1
                to: 20
                stepSize: 1
                onValueChanged: {
                    Config.options.overview.rows = value;
                }
            }
            ConfigSpinBox {
                text: Translation.tr("Columns")
                value: Config.options.overview.columns
                from: 1
                to: 20
                stepSize: 1
                onValueChanged: {
                    Config.options.overview.columns = value;
                }
            }
        }
    }

    ContentSection {
        title: Translation.tr("Screenshot Tool")

        ConfigSwitch {
            text: Translation.tr('Show regions of potential interest')
            checked: Config.options.screenshotTool.showContentRegions
            onCheckedChanged: {
                Config.options.screenshotTool.showContentRegions = checked;
            }
        }        
    }
}
