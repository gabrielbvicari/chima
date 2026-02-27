import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions

ContentPage {
    forceWidth: true

    property bool initialized: false

    Component.onCompleted: {
        initialized = true;
    }

    Process {
        id: hypridleReloadProc
        running: false
        command: ["systemctl", "--user", "restart", "hypridle.service"]
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                console.log("Hypridle reloaded successfully")
            } else {
                console.log("Failed to reload hypridle:", exitCode)
            }
        }
    }

    Timer {
        id: applyTimer
        interval: 1000
        repeat: false
        onTriggered: {
            const lockTimeout = lockTimeoutSpinBox.value;
            const dpmsTimeout = dpmsTimeoutSpinBox.value;
            const suspendTimeout = suspendTimeoutSpinBox.value;
            const enableLock = enableLockSwitch.checked;
            const enableDpms = enableDpmsSwitch.checked;
            const enableSuspend = enableSuspendSwitch.checked;

            console.log(`[PowerConfig] Applying settings: lock=${lockTimeout}, dpms=${dpmsTimeout}, suspend=${suspendTimeout}`);

            const scriptPath = FileUtils.trimFileProtocol(`${Directories.scriptPath}/hypridle-manager.sh`);
            console.log(`[PowerConfig] Script path: ${scriptPath}`);

            // Write to hypridle.conf
            Quickshell.execDetached([
                scriptPath,
                "--set",
                String(lockTimeout),
                String(dpmsTimeout),
                String(suspendTimeout),
                enableLock ? "1" : "0",
                enableDpms ? "1" : "0",
                enableSuspend ? "1" : "0"
            ]);

            // Reload hypridle
            hypridleReloadProc.running = true;
        }
    }

    function applyHypridleSettings() {
        console.log(`[PowerConfig] applyHypridleSettings called`);
        applyTimer.restart();
    }

    ContentSection {
        title: Translation.tr("Power Management")

        ContentSubsection {
            title: Translation.tr("Timeouts")

            ConfigSpinBox {
                id: lockTimeoutSpinBox
                text: Translation.tr("Lock screen after (s)")
                value: Config.options.power.hypridle.lockTimeout
                from: 0
                to: 3600
                stepSize: 10
                enabled: enableLockSwitch.checked
                onValueChanged: {
                    if (!initialized) return;
                    Config.options.power.hypridle.lockTimeout = value;
                    console.log(`[PowerConfig] lockTimeout changed to ${value}`);
                    applyHypridleSettings();
                }
            }

            ConfigSpinBox {
                id: dpmsTimeoutSpinBox
                text: Translation.tr("Turn off display after (s)")
                value: Config.options.power.hypridle.dpmsTimeout
                from: 0
                to: 3600
                stepSize: 10
                enabled: enableDpmsSwitch.checked
                onValueChanged: {
                    if (!initialized) return;
                    Config.options.power.hypridle.dpmsTimeout = value;
                    console.log(`[PowerConfig] dpmsTimeout changed to ${value}`);
                    applyHypridleSettings();
                }
            }

            ConfigSpinBox {
                id: suspendTimeoutSpinBox
                text: Translation.tr("Suspend system after (s)")
                value: Config.options.power.hypridle.suspendTimeout
                from: 0
                to: 7200
                stepSize: 10
                enabled: enableSuspendSwitch.checked
                onValueChanged: {
                    if (!initialized) return;
                    Config.options.power.hypridle.suspendTimeout = value;
                    console.log(`[PowerConfig] suspendTimeout changed to ${value}`);
                    applyHypridleSettings();
                }
            }
        }

        ContentSubsection {
            title: Translation.tr("Enable/Disable Actions")

            ConfigRow {
                uniform: true

                ConfigSwitch {
                    id: enableLockSwitch
                    text: Translation.tr("Enable lock screen")
                    checked: Config.options.power.hypridle.enableLock
                    onCheckedChanged: {
                        if (!initialized) return;
                        Config.options.power.hypridle.enableLock = checked;
                        applyHypridleSettings();
                    }
                }

                ConfigSwitch {
                    id: enableDpmsSwitch
                    text: Translation.tr("Enable display off")
                    checked: Config.options.power.hypridle.enableDpms
                    onCheckedChanged: {
                        if (!initialized) return;
                        Config.options.power.hypridle.enableDpms = checked;
                        applyHypridleSettings();
                    }
                }
            }

            ConfigSwitch {
                id: enableSuspendSwitch
                text: Translation.tr("Enable automatic suspend")
                checked: Config.options.power.hypridle.enableSuspend
                onCheckedChanged: {
                    if (!initialized) return;
                    Config.options.power.hypridle.enableSuspend = checked;
                    applyHypridleSettings();
                }
            }
        }
    }

    ContentSection {
        title: Translation.tr("Display Power Management")

        ConfigRow {
            uniform: true

            ConfigSwitch {
                text: Translation.tr("Wake on mouse movement")
                checked: Config.options.power.misc.mouse_move_enables_dpms
                onCheckedChanged: {
                    if (!initialized) return;
                    Config.options.power.misc.mouse_move_enables_dpms = checked;
                    Quickshell.execDetached(["hyprctl", "keyword", "misc:mouse_move_enables_dpms", checked ? "true" : "false"]);
                    const scriptPath = FileUtils.trimFileProtocol(`${Directories.scriptPath}/hyprland-settings.sh`);
                    Quickshell.execDetached([scriptPath, "--set", "misc.mouse_move_enables_dpms", checked ? "true" : "false"]);
                }
            }

            ConfigSwitch {
                text: Translation.tr("Wake on key press")
                checked: Config.options.power.misc.key_press_enables_dpms
                onCheckedChanged: {
                    if (!initialized) return;
                    Config.options.power.misc.key_press_enables_dpms = checked;
                    Quickshell.execDetached(["hyprctl", "keyword", "misc:key_press_enables_dpms", checked ? "true" : "false"]);
                    const scriptPath = FileUtils.trimFileProtocol(`${Directories.scriptPath}/hyprland-settings.sh`);
                    Quickshell.execDetached([scriptPath, "--set", "misc.key_press_enables_dpms", checked ? "true" : "false"]);
                }
            }
        }
    }

    ContentSection {
        title: Translation.tr("Battery")

        ConfigRow {
            uniform: true
            ConfigSpinBox {
                text: Translation.tr("Low warning")
                value: Config.options.battery.low
                from: 0
                to: 100
                stepSize: 5
                onValueChanged: {
                    if (!initialized) return;
                    Config.options.battery.low = value;
                }
            }
            ConfigSpinBox {
                text: Translation.tr("Critical warning")
                value: Config.options.battery.critical
                from: 0
                to: 100
                stepSize: 5
                onValueChanged: {
                    if (!initialized) return;
                    Config.options.battery.critical = value;
                }
            }
        }
        ConfigRow {
            uniform: true
            ConfigSwitch {
                text: Translation.tr("Automatic suspend")
                checked: Config.options.battery.automaticSuspend
                onCheckedChanged: {
                    if (!initialized) return;
                    Config.options.battery.automaticSuspend = checked;
                }
            }
            ConfigSpinBox {
                text: Translation.tr("Suspend at")
                value: Config.options.battery.suspend
                from: 0
                to: 100
                stepSize: 5
                onValueChanged: {
                    if (!initialized) return;
                    Config.options.battery.suspend = value;
                }
            }
        }
    }
}
