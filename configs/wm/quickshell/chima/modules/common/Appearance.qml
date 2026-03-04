import QtQuick
import Quickshell
import qs.modules.common.functions
pragma Singleton
pragma ComponentBehavior: Bound

Singleton {
    id: root
    property QtObject m3colors
    property QtObject animation
    property QtObject animationCurves
    property QtObject colors
    property QtObject rounding
    property QtObject font
    property QtObject sizes
    property string syntaxHighlightingTheme

    // Extremely conservative transparency values for consistency and readability
    property real transparency: Config.options?.appearance.transparency ? (m3colors.darkmode ? 0.1 : 0.07) : 0
    property real contentTransparency: Config.options?.appearance.transparency ? (m3colors.darkmode ? 0.55 : 0.55) : 0

    m3colors: QtObject {
        property bool darkmode: false
        property bool transparent: false
        property color m3primary_paletteKeyColor: "#8B8B8B"
        property color m3secondary_paletteKeyColor: "#8B8B8B"
        property color m3tertiary_paletteKeyColor: "#8B8B8B"
        property color m3neutral_paletteKeyColor: "#8B8B8B"
        property color m3neutral_variant_paletteKeyColor: "#8B8B8B"
        property color m3background: "#131313"
        property color m3onBackground: "#E5E2E1"
        property color m3surface: "#131313"
        property color m3surfaceDim: "#131313"
        property color m3surfaceBright: "#393939"
        property color m3surfaceContainerLowest: "#0E0E0E"
        property color m3surfaceContainerLow: "#1B1B1B"
        property color m3surfaceContainer: "#1F1F1F"
        property color m3surfaceContainerHigh: "#2A2A2A"
        property color m3surfaceContainerHighest: "#353535"
        property color m3onSurface: "#E5E2E1"
        property color m3surfaceVariant: "#474747"
        property color m3onSurfaceVariant: "#C8C6C5"
        property color m3inverseSurface: "#E5E2E1"
        property color m3inverseOnSurface: "#313030"
        property color m3outline: "#929090"
        property color m3outlineVariant: "#474747"
        property color m3shadow: "#000000"
        property color m3scrim: "#000000"
        property color m3surfaceTint: "#C9C6C5"
        property color m3primary: "#C9C6C5"
        property color m3onPrimary: "#313030"
        property color m3primaryContainer: "#484646"
        property color m3onPrimaryContainer: "#E5E2E1"
        property color m3inversePrimary: "#605E5E"
        property color m3secondary: "#C8C6C5"
        property color m3onSecondary: "#313030"
        property color m3secondaryContainer: "#474646"
        property color m3onSecondaryContainer: "#E4E2E1"
        property color m3tertiary: "#C8C6C5"
        property color m3onTertiary: "#313030"
        property color m3tertiaryContainer: "#474646"
        property color m3onTertiaryContainer: "#E4E2E1"
        property color m3error: "#FFB4AB"
        property color m3onError: "#690005"
        property color m3errorContainer: "#93000A"
        property color m3onErrorContainer: "#FFDAD6"
        property color m3primaryFixed: "#E5E2E1"
        property color m3primaryFixedDim: "#C9C6C5"
        property color m3onPrimaryFixed: "#1B1B1B"
        property color m3onPrimaryFixedVariant: "#484646"
        property color m3secondaryFixed: "#E4E2E1"
        property color m3secondaryFixedDim: "#C8C6C5"
        property color m3onSecondaryFixed: "#1B1B1B"
        property color m3onSecondaryFixedVariant: "#474646"
        property color m3tertiaryFixed: "#E4E2E1"
        property color m3tertiaryFixedDim: "#C8C6C5"
        property color m3onTertiaryFixed: "#1B1B1B"
        property color m3onTertiaryFixedVariant: "#474646"
        property color m3success: "#B5CCBA"
        property color m3onSuccess: "#213528"
        property color m3successContainer: "#374B3E"
        property color m3onSuccessContainer: "#D1E9D6"
        property color term0: "#E5E2E1"
        property color term1: "#C9C6C5"
        property color term2: "#929090"
        property color term3: "#C8C6C5"
        property color term4: "#929090"
        property color term5: "#C9C6C5"
        property color term6: "#929090"
        property color term7: "#1B1B1B"
        property color term8: "#131313"
        property color term9: "#C9C6C5"
        property color term10: "#929090"
        property color term11: "#C8C6C5"
        property color term12: "#929090"
        property color term13: "#C9C6C5"
        property color term14: "#929090"
        property color term15: "#0E0E0E"
    }

    colors: QtObject {
        property color colSubtext: m3colors.m3outline
        property color colLayer0: ColorUtils.mix(ColorUtils.transparentize(m3colors.m3background, root.transparency), m3colors.m3primary, Config.options.appearance.extraBackgroundTint ? 0.99 : 1)
        property color colOnLayer0: m3colors.m3onBackground
        property color colLayer0Hover: ColorUtils.transparentize(ColorUtils.mix(colLayer0, colOnLayer0, 0.9, root.contentTransparency))
        property color colLayer0Active: ColorUtils.transparentize(ColorUtils.mix(colLayer0, colOnLayer0, 0.8, root.contentTransparency))
        property color colLayer1: ColorUtils.transparentize(ColorUtils.mix(m3colors.m3surfaceContainerLow, m3colors.m3background, 0.8), root.contentTransparency);
        property color colOnLayer1: m3colors.m3onSurfaceVariant;
        property color colOnLayer1Inactive: ColorUtils.mix(colOnLayer1, colLayer1, 0.45);
        property color colLayer2: ColorUtils.transparentize(ColorUtils.mix(m3colors.m3surfaceContainer, m3colors.m3surfaceContainerHigh, 0.1), root.contentTransparency)
        property color colOnLayer2: m3colors.m3onSurface;
        property color colOnLayer2Disabled: ColorUtils.mix(colOnLayer2, m3colors.m3background, 0.4);
        property color colLayer3: ColorUtils.transparentize(ColorUtils.mix(m3colors.m3surfaceContainerHigh, m3colors.m3onSurface, 0.96), root.contentTransparency)
        property color colOnLayer3: m3colors.m3onSurface;
        property color colLayer1Hover: ColorUtils.transparentize(ColorUtils.mix(colLayer1, colOnLayer1, 0.92), root.contentTransparency)
        property color colLayer1Active: ColorUtils.transparentize(ColorUtils.mix(colLayer1, colOnLayer1, 0.85), root.contentTransparency);
        property color colLayer2Hover: ColorUtils.transparentize(ColorUtils.mix(colLayer2, colOnLayer2, 0.90), root.contentTransparency)
        property color colLayer2Active: ColorUtils.transparentize(ColorUtils.mix(colLayer2, colOnLayer2, 0.80), root.contentTransparency);
        property color colLayer2Disabled: ColorUtils.transparentize(ColorUtils.mix(colLayer2, m3colors.m3background, 0.8), root.contentTransparency);
        property color colLayer3Hover: ColorUtils.transparentize(ColorUtils.mix(colLayer3, colOnLayer3, 0.90), root.contentTransparency)
        property color colLayer3Active: ColorUtils.transparentize(ColorUtils.mix(colLayer3, colOnLayer3, 0.80), root.contentTransparency);
        property color colLayer4: ColorUtils.transparentize(ColorUtils.mix(m3colors.m3surfaceContainerHighest, m3colors.m3onSurface, 0.96), root.contentTransparency)
        property color colOnLayer4: m3colors.m3onSurface;
        property color colLayer4Hover: ColorUtils.transparentize(ColorUtils.mix(colLayer4, colOnLayer4, 0.90), root.contentTransparency)
        property color colLayer4Active: ColorUtils.transparentize(ColorUtils.mix(colLayer4, colOnLayer4, 0.80), root.contentTransparency);
        property color colPrimary: m3colors.m3primary
        property color colOnPrimary: m3colors.m3onPrimary
        property color colPrimaryHover: ColorUtils.mix(colors.colPrimary, colLayer1Hover, 0.87)
        property color colPrimaryActive: ColorUtils.mix(colors.colPrimary, colLayer1Active, 0.7)
        property color colPrimaryContainer: m3colors.m3primaryContainer
        property color colPrimaryContainerHover: ColorUtils.mix(colors.colPrimaryContainer, colLayer1Hover, 0.7)
        property color colPrimaryContainerActive: ColorUtils.mix(colors.colPrimaryContainer, colLayer1Active, 0.6)
        property color colOnPrimaryContainer: m3colors.m3onPrimaryContainer
        property color colSecondary: m3colors.m3secondary
        property color colSecondaryHover: ColorUtils.mix(m3colors.m3secondary, colLayer1Hover, 0.85)
        property color colSecondaryActive: ColorUtils.mix(m3colors.m3secondary, colLayer1Active, 0.4)
        property color colSecondaryContainer: m3colors.m3secondaryContainer
        property color colSecondaryContainerHover: ColorUtils.mix(m3colors.m3secondaryContainer, m3colors.m3onSecondaryContainer, 0.90)
        property color colSecondaryContainerActive: ColorUtils.mix(m3colors.m3secondaryContainer, colLayer1Active, 0.54)
        property color colOnSecondaryContainer: m3colors.m3onSecondaryContainer
        property color colSurfaceContainerLow: ColorUtils.transparentize(m3colors.m3surfaceContainerLow, root.contentTransparency)
        property color colSurfaceContainer: ColorUtils.transparentize(m3colors.m3surfaceContainer, root.contentTransparency)
        property color colSurfaceContainerHigh: ColorUtils.transparentize(m3colors.m3surfaceContainerHigh, root.contentTransparency)
        property color colSurfaceContainerHighest: ColorUtils.transparentize(m3colors.m3surfaceContainerHighest, root.contentTransparency)
        property color colSurfaceContainerHighestHover: ColorUtils.mix(m3colors.m3surfaceContainerHighest, m3colors.m3onSurface, 0.95)
        property color colSurfaceContainerHighestActive: ColorUtils.mix(m3colors.m3surfaceContainerHighest, m3colors.m3onSurface, 0.85)
        property color colTooltip: m3colors.darkmode ? ColorUtils.mix(m3colors.m3background, "#3C4043", 0.5) : "#3C4043" // m3colors.m3inverseSurface in the specs, but the m3 website actually uses #3C4043
        property color colOnTooltip: "#F8F9FA" // m3colors.m3inverseOnSurface in the specs, but the m3 website actually uses this color
        property color colScrim: ColorUtils.transparentize(m3colors.m3scrim, 0.5)
        property color colShadow: ColorUtils.transparentize(m3colors.m3shadow, 0.7)
        property color colOutlineVariant: m3colors.m3outlineVariant
    }

    rounding: QtObject {
        property int unsharpen: 2
        property int unsharpenmore: 6
        property int verysmall: 8
        property int small: 12
        property int normal: 17
        property int large: 23
        property int verylarge: 30
        property int full: 9999
        property int screenRounding: large
        property int windowRounding: 18
    }

    font: QtObject {
        property QtObject family: QtObject {
            property string main: "Rubik"
            property string title: "Gabarito"
            property string iconMaterial: "Material Symbols Rounded"
            property string iconNerd: "SpaceMono NF"
            property string monospace: "JetBrains Mono NF"
            property string reading: "Readex Pro"
            property string expressive: "Space Grotesk"
        }
        property QtObject pixelSize: QtObject {
            property int smallest: 10
            property int smaller: 12
            property int small: 15
            property int normal: 16
            property int large: 17
            property int larger: 19
            property int huge: 22
            property int hugeass: 23
            property int title: huge
        }
    }

    animationCurves: QtObject {
        readonly property list<real> expressiveFastSpatial: [0.42, 1.67, 0.21, 0.90, 1, 1] // Default, 350ms
        readonly property list<real> expressiveDefaultSpatial: [0.38, 1.21, 0.22, 1.00, 1, 1] // Default, 500ms
        readonly property list<real> expressiveSlowSpatial: [0.39, 1.29, 0.35, 0.98, 1, 1] // Default, 650ms
        readonly property list<real> expressiveEffects: [0.34, 0.80, 0.34, 1.00, 1, 1] // Default, 200ms
        readonly property list<real> emphasized: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82, 0.25, 1, 1, 1]
        readonly property list<real> emphasizedFirstHalf: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82]
        readonly property list<real> emphasizedLastHalf: [5 / 24, 0.82, 0.25, 1, 1, 1]
        readonly property list<real> emphasizedAccel: [0.3, 0, 0.8, 0.15, 1, 1]
        readonly property list<real> emphasizedDecel: [0.05, 0.7, 0.1, 1, 1, 1]
        readonly property list<real> standard: [0.2, 0, 0, 1, 1, 1]
        readonly property list<real> standardAccel: [0.3, 0, 1, 1, 1, 1]
        readonly property list<real> standardDecel: [0, 0, 0, 1, 1, 1]
        readonly property real expressiveFastSpatialDuration: 350
        readonly property real expressiveDefaultSpatialDuration: 500
        readonly property real expressiveSlowSpatialDuration: 650
        readonly property real expressiveEffectsDuration: 200
    }

    animation: QtObject {
        property QtObject elementMove: QtObject {
            property int duration: animationCurves.expressiveDefaultSpatialDuration
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animationCurves.expressiveDefaultSpatial
            property int velocity: 650
            property Component numberAnimation: Component {
                NumberAnimation {
                    duration: root.animation.elementMove.duration
                    easing.type: root.animation.elementMove.type
                    easing.bezierCurve: root.animation.elementMove.bezierCurve
                }
            }
            property Component colorAnimation: Component {
                ColorAnimation {
                    duration: root.animation.elementMove.duration
                    easing.type: root.animation.elementMove.type
                    easing.bezierCurve: root.animation.elementMove.bezierCurve
                }
            }
        }
        property QtObject elementMoveEnter: QtObject {
            property int duration: 400
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animationCurves.emphasizedDecel
            property int velocity: 650
            property Component numberAnimation: Component {
                NumberAnimation {
                    duration: root.animation.elementMoveEnter.duration
                    easing.type: root.animation.elementMoveEnter.type
                    easing.bezierCurve: root.animation.elementMoveEnter.bezierCurve
                }
            }
        }
        property QtObject elementMoveExit: QtObject {
            property int duration: 200
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animationCurves.emphasizedAccel
            property int velocity: 650
            property Component numberAnimation: Component {
                NumberAnimation {
                    duration: root.animation.elementMoveExit.duration
                    easing.type: root.animation.elementMoveExit.type
                    easing.bezierCurve: root.animation.elementMoveExit.bezierCurve
                }
            }
        }
        property QtObject elementMoveFast: QtObject {
            property int duration: animationCurves.expressiveEffectsDuration
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animationCurves.expressiveEffects
            property int velocity: 850
            property Component colorAnimation: Component { ColorAnimation {
                duration: root.animation.elementMoveFast.duration
                easing.type: root.animation.elementMoveFast.type
                easing.bezierCurve: root.animation.elementMoveFast.bezierCurve
            }}
            property Component numberAnimation: Component { NumberAnimation {
                    duration: root.animation.elementMoveFast.duration
                    easing.type: root.animation.elementMoveFast.type
                    easing.bezierCurve: root.animation.elementMoveFast.bezierCurve
            }}
        }

        property QtObject clickBounce: QtObject {
            property int duration: 200
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animationCurves.expressiveFastSpatial
            property int velocity: 850
            property Component numberAnimation: Component { NumberAnimation {
                    duration: root.animation.clickBounce.duration
                    easing.type: root.animation.clickBounce.type
                    easing.bezierCurve: root.animation.clickBounce.bezierCurve
            }}
        }
        property QtObject scroll: QtObject {
            property int duration: 400
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animationCurves.standardDecel
        }
        property QtObject menuDecel: QtObject {
            property int duration: 350
            property int type: Easing.OutExpo
        }
    }

    sizes: QtObject {
        property real baseBarHeight: 40
        property real barHeight: Config.options.bar.cornerStyle === 1 ? 
            (baseBarHeight + Appearance.sizes.hyprlandGapsOut * 2) : baseBarHeight
        property real barCenterSideModuleWidth: Config.options?.bar.verbose ? 360 : 140
        property real barCenterSideModuleWidthShortened: 280
        property real barCenterSideModuleWidthHellaShortened: 190
        property real barShortenScreenWidthThreshold: 1200 // Shorten if screen width is at most this value
        property real barHellaShortenScreenWidthThreshold: 1000 // Shorten even more...
        property real sidebarWidth: 460
        property real sidebarWidthExtended: 750
        property real osdWidth: 200
        property real mediaControlsWidth: 440
        property real mediaControlsHeight: 160
        property real notificationPopupWidth: 410
        property real searchWidthCollapsed: 260
        property real searchWidth: 450
        property real hyprlandGapsOut: 10
        property real elevationMargin: 10
        property real fabShadowRadius: 5
        property real fabHoveredShadowRadius: 7
    }

    syntaxHighlightingTheme: Appearance.m3colors.darkmode ? "Monokai" : "ayu Light"
}
