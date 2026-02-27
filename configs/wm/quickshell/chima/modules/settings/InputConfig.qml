import QtQuick
import QtQuick.Layouts
import Quickshell
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets

ContentPage {
    forceWidth: true

    property bool initialized: false

    Component.onCompleted: {
        initialized = true;
    }

    ContentSection {
        title: Translation.tr("Keyboard")

        ConfigSwitch {
            text: Translation.tr("Numlock on startup")
            checked: Config.options.input.numlock_by_default
            onCheckedChanged: {
                if (!initialized) return;
                Config.options.input.numlock_by_default = checked;
                Quickshell.execDetached(["hyprctl", "keyword", "input:numlock_by_default", checked ? "true" : "false"]);
                const scriptPath = FileUtils.trimFileProtocol(`${Directories.scriptPath}/hyprland-settings.sh`);
                Quickshell.execDetached([scriptPath, "--set", "input.numlock_by_default", checked ? "true" : "false"]);
            }
        }

        ConfigRow {
            uniform: true

            ConfigSpinBox {
                text: Translation.tr("Repeat delay (ms)")
                value: Config.options.input.repeat_delay
                from: 100
                to: 1000
                stepSize: 50
                onValueChanged: {
                    if (!initialized) return;
                    Config.options.input.repeat_delay = value;
                    Quickshell.execDetached(["hyprctl", "keyword", "input:repeat_delay", String(value)]);
                    const scriptPath = FileUtils.trimFileProtocol(`${Directories.scriptPath}/hyprland-settings.sh`);
                    Quickshell.execDetached([scriptPath, "--set", "input.repeat_delay", String(value)]);
                }
            }

            ConfigSpinBox {
                text: Translation.tr("Repeat rate")
                value: Config.options.input.repeat_rate
                from: 10
                to: 100
                stepSize: 5
                onValueChanged: {
                    if (!initialized) return;
                    Config.options.input.repeat_rate = value;
                    Quickshell.execDetached(["hyprctl", "keyword", "input:repeat_rate", String(value)]);
                    const scriptPath = FileUtils.trimFileProtocol(`${Directories.scriptPath}/hyprland-settings.sh`);
                    Quickshell.execDetached([scriptPath, "--set", "input.repeat_rate", String(value)]);
                }
            }
        }
    }

    ContentSection {
        title: Translation.tr("Mouse")

        ConfigSwitch {
            text: Translation.tr("Focus follows mouse")
            checked: Config.options.input.follow_mouse
            onCheckedChanged: {
                if (!initialized) return;
                Config.options.input.follow_mouse = checked;
                Quickshell.execDetached(["hyprctl", "keyword", "input:follow_mouse", checked ? "1" : "0"]);
                const scriptPath = FileUtils.trimFileProtocol(`${Directories.scriptPath}/hyprland-settings.sh`);
                Quickshell.execDetached([scriptPath, "--set", "input.follow_mouse", checked ? "1" : "0"]);
            }
        }
    }

    ContentSection {
        title: Translation.tr("Touchpad")

        ConfigRow {
            uniform: true

            ConfigSwitch {
                text: Translation.tr("Natural scrolling")
                checked: Config.options.input.touchpad.natural_scroll
                onCheckedChanged: {
                    if (!initialized) return;
                    Config.options.input.touchpad.natural_scroll = checked;
                    Quickshell.execDetached(["hyprctl", "keyword", "input:touchpad:natural_scroll", checked ? "true" : "false"]);
                    const scriptPath = FileUtils.trimFileProtocol(`${Directories.scriptPath}/hyprland-settings.sh`);
                    Quickshell.execDetached([scriptPath, "--set", "input.touchpad.natural_scroll", checked ? "yes" : "no"]);
                }
            }

            ConfigSwitch {
                text: Translation.tr("Disable while typing")
                checked: Config.options.input.touchpad.disable_while_typing
                onCheckedChanged: {
                    if (!initialized) return;
                    Config.options.input.touchpad.disable_while_typing = checked;
                    Quickshell.execDetached(["hyprctl", "keyword", "input:touchpad:disable_while_typing", checked ? "true" : "false"]);
                    const scriptPath = FileUtils.trimFileProtocol(`${Directories.scriptPath}/hyprland-settings.sh`);
                    Quickshell.execDetached([scriptPath, "--set", "input.touchpad.disable_while_typing", checked ? "true" : "false"]);
                }
            }
        }

        ConfigRow {
            uniform: true

            ConfigSwitch {
                text: Translation.tr("Tap to click")
                checked: Config.options.input.touchpad.tap_to_click
                onCheckedChanged: {
                    if (!initialized) return;
                    Config.options.input.touchpad.tap_to_click = checked;
                    Quickshell.execDetached(["hyprctl", "keyword", "input:touchpad:tap-to-click", checked ? "true" : "false"]);
                    const scriptPath = FileUtils.trimFileProtocol(`${Directories.scriptPath}/hyprland-settings.sh`);
                    Quickshell.execDetached([scriptPath, "--set", "input.touchpad.tap-to-click", checked ? "true" : "false"]);
                }
            }

            ConfigSwitch {
                text: Translation.tr("Click finger behavior")
                checked: Config.options.input.touchpad.clickfinger_behavior
                onCheckedChanged: {
                    if (!initialized) return;
                    Config.options.input.touchpad.clickfinger_behavior = checked;
                    Quickshell.execDetached(["hyprctl", "keyword", "input:touchpad:clickfinger_behavior", checked ? "true" : "false"]);
                    const scriptPath = FileUtils.trimFileProtocol(`${Directories.scriptPath}/hyprland-settings.sh`);
                    Quickshell.execDetached([scriptPath, "--set", "input.touchpad.clickfinger_behavior", checked ? "true" : "false"]);
                }
            }
        }

        ConfigSpinBox {
            text: Translation.tr("Scroll factor (%)")
            value: Config.options.input.touchpad.scroll_factor
            from: 10
            to: 200
            stepSize: 10
            onValueChanged: {
                if (!initialized) return;
                Config.options.input.touchpad.scroll_factor = value;
                const scrollValue = value / 100;
                Quickshell.execDetached(["hyprctl", "keyword", "input:touchpad:scroll_factor", String(scrollValue)]);
                const scriptPath = FileUtils.trimFileProtocol(`${Directories.scriptPath}/hyprland-settings.sh`);
                Quickshell.execDetached([scriptPath, "--set", "input.touchpad.scroll_factor", String(scrollValue)]);
            }
        }
    }
}
