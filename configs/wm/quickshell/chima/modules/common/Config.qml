pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property string filePath: Directories.shellConfigPath
    property alias options: configOptionsJsonAdapter

    function setNestedValue(nestedKey, value) {
        let keys = nestedKey.split(".");
        let obj = root.options;
        let parents = [obj];

        // Traverse and collect parent objects
        for (let i = 0; i < keys.length - 1; ++i) {
            if (!obj[keys[i]] || typeof obj[keys[i]] !== "object") {
                obj[keys[i]] = {};
            }
            obj = obj[keys[i]];
            parents.push(obj);
        }

        // Convert value to correct type using JSON.parse when safe
        let convertedValue = value;
        if (typeof value === "string") {
            let trimmed = value.trim();
            if (trimmed === "true" || trimmed === "false" || !isNaN(Number(trimmed))) {
                try {
                    convertedValue = JSON.parse(trimmed);
                } catch (e) {
                    convertedValue = value;
                }
            }
        }

        obj[keys[keys.length - 1]] = convertedValue;
    }

    FileView {
        path: root.filePath

        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        onLoadFailed: error => {
            if (error == FileViewError.FileNotFound) {
                writeAdapter();
            }
        }

        JsonAdapter {
            id: configOptionsJsonAdapter

            property JsonObject appearance: JsonObject {
                property bool extraBackgroundTint: true
                property int fakeScreenRounding: 2 // 0: None | 1: Always | 2: When not fullscreen
                property bool transparency: false
                property JsonObject wallpaperTheming: JsonObject {
                    property bool enableAppsAndShell: true
                    property bool enableQtApps: true
                    property bool enableTerminal: true
                }
                property JsonObject palette: JsonObject {
                    property string type: "scheme-monochrome" // Allowed: auto, scheme-content, scheme-expressive, scheme-fidelity, scheme-fruit-salad, scheme-monochrome, scheme-neutral, scheme-rainbow, scheme-tonal-spot
                }
            }

            property JsonObject audio: JsonObject {
                // Values in %
                property JsonObject protection: JsonObject {
                    // Prevent sudden bangs
                    property bool enable: true
                    property real maxAllowedIncrease: 10
                    property real maxAllowed: 90 // Realistically should already provide some protection when it's 99...
                }
            }

            property JsonObject apps: JsonObject {
                property string bluetooth: "kcmshell6 kcm_bluetooth"
                property string network: "plasmawindowed org.kde.plasma.networkmanagement"
                property string networkEthernet: "kcmshell6 kcm_networkmanagement"
                property string taskManager: "plasma-systemmonitor --page-name Processes"
                property string terminal: "kitty -1" // This is only for shell actions
            }

            property JsonObject background: JsonObject {
                property bool fixedClockPosition: false
                property real clockX: -500
                property real clockY: -500
                property string wallpaperPath: ""
                property JsonObject parallax: JsonObject {
                    property bool enableWorkspace: true
                    property real workspaceZoom: 1.0 // Relative to your screen, not wallpaper size
                    property bool enableSidebar: true
                }
            }

            property JsonObject bar: JsonObject {
                property bool bottom: false // Instead of top
                property int cornerStyle: 0 // 0: Hug | 1: Float | 2: Plain rectangle
                property bool borderless: false // true for no grouping of items
                property string topLeftIcon: "spark" // Options: distro, spark
                property bool showBackground: true
                property bool verbose: true
                property JsonObject resources: JsonObject {
                    property bool alwaysShowSwap: true
                    property bool alwaysShowCpu: false
                }
                property list<string> screenList: [] // List of names, like "eDP-1", find out with 'hyprctl monitors' command
                property JsonObject utilButtons: JsonObject {
                    property bool showScreenSnip: true
                    property bool showColorPicker: false
                    property bool showMicToggle: false
                    property bool showKeyboardToggle: true
                    property bool showDarkModeToggle: true
                }
                property JsonObject tray: JsonObject {
                    property bool monochromeIcons: true
                }
                property JsonObject workspaces: JsonObject {
                    property bool monochromeIcons: true
                    property int shown: 10
                    property bool showAppIcons: true
                    property bool alwaysShowNumbers: false
                    property int showNumberDelay: 300 // milliseconds
                }
                property JsonObject weather: JsonObject {
                    property bool enable: false
                    property bool enableGPS: true // gps based location
                    property string city: "" // When 'enableGPS' is false
                    property bool useUSCS: false // Instead of metric (SI) units
                    property int fetchInterval: 10 // minutes
                }
            }

            property JsonObject battery: JsonObject {
                property int low: 20
                property int critical: 5
                property bool automaticSuspend: true
                property int suspend: 3
            }

            property JsonObject dock: JsonObject {
                property bool enable: false
                property bool monochromeIcons: true
                property real height: 60
                property real hoverRegionHeight: 2
                property bool pinnedOnStartup: false
                property bool hoverToReveal: true // When false, only reveals on empty workspace
                property list<string> pinnedApps: [ // IDs of pinned entries
                    "org.kde.dolphin", "kitty",]
                property list<string> ignoredAppRegexes: []
            }

            property JsonObject networking: JsonObject {
                property string userAgent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36"
            }

            property JsonObject osd: JsonObject {
                property int timeout: 1000
            }

            property JsonObject osk: JsonObject {
                property string layout: "qwerty_full"
                property bool pinnedOnStartup: false
            }

            property JsonObject overview: JsonObject {
                property real scale: 0.18 // Relative to screen size
                property real rows: 2
                property real columns: 5
            }

            property JsonObject resources: JsonObject {
                property int updateInterval: 3000
            }

            property JsonObject search: JsonObject {
                property int nonAppResultDelay: 30 // This prevents lagging when typing
                property string engineBaseUrl: "https://www.google.com/search?q="
                property list<string> excludedSites: ["quora.com"]
                property bool sloppy: false // Uses levenshtein distance based scoring instead of fuzzy sort. Very weird.
                property JsonObject prefix: JsonObject {
                    property string action: "/"
                    property string clipboard: ";"
                    property string emojis: ":"
                }
            }

            property JsonObject time: JsonObject {
                // https://doc.qt.io/qt-6/qtime.html#toString
                property string format: "hh:mm"
                property string dateFormat: "ddd, dd/MM"
            }

            property JsonObject windows: JsonObject {
                property bool showTitlebar: true // Client-side decoration for shell apps
                property bool centerTitle: true
            }

            property JsonObject hacks: JsonObject {
                property int arbitraryRaceConditionDelay: 20 // milliseconds
            }

            property JsonObject screenshotTool: JsonObject {
                property bool showContentRegions: true
            }

            property JsonObject hyprland: JsonObject {
                property JsonObject general: JsonObject {
                    property int gaps_in: 4
                    property int gaps_out: 5
                    property int gaps_workspaces: 50
                    property int border_size: 1
                }
                property JsonObject decoration: JsonObject {
                    property int rounding: 18
                    property int active_opacity: 90 // Stored as percentage
                    property int inactive_opacity: 75
                    property int fullscreen_opacity: 100
                    property JsonObject blur: JsonObject {
                        property bool enabled: true
                        property int size: 14
                        property int passes: 3
                        property int brightness: 100 // Stored as percentage
                    }
                    property JsonObject shadow: JsonObject {
                        property bool enabled: true
                        property int range: 30
                    }
                    property bool dim_inactive: true
                    property int dim_strength: 25 // Stored as percentage (will be /1000 for Hyprland)
                }
            }

            property JsonObject input: JsonObject {
                property bool numlock_by_default: true
                property int repeat_delay: 250
                property int repeat_rate: 35
                property bool follow_mouse: true
                property JsonObject touchpad: JsonObject {
                    property bool natural_scroll: true
                    property bool disable_while_typing: true
                    property bool tap_to_click: true
                    property bool clickfinger_behavior: true
                    property int scroll_factor: 50 // Stored as percentage
                }
            }

            property JsonObject power: JsonObject {
                property JsonObject hypridle: JsonObject {
                    property int lockTimeout: 300
                    property int dpmsTimeout: 600
                    property int suspendTimeout: 900
                    property bool enableLock: true
                    property bool enableDpms: true
                    property bool enableSuspend: true
                }
                property JsonObject misc: JsonObject {
                    property bool mouse_move_enables_dpms: true
                    property bool key_press_enables_dpms: true
                }
            }
        }
    }
}
