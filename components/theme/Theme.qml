pragma Singleton

import QtQuick
import Quickshell

Singleton {
  // Colors
  readonly property color barBackground: "#1e1e2e"
  readonly property color barText: "#cdd6f4"
  readonly property color popupBackground: "#181825"
  readonly property color buttonBackground: "#313244"
  readonly property color indicatorBackground: "transparent"
  readonly property color indicatorHoverBackground: "#45475a"
  readonly property color textPrimary: "#cdd6f4"
  readonly property color textHeading: "#cdd6f4"
  readonly property color textMuted: "#a6adc8"
  readonly property color textError: "#f38ba8"
  readonly property color textSuccess: "#a6e3a1"

  // Spacing and shape
  readonly property int spacingXs: 2
  readonly property int spacingSm: 4
  readonly property int spacingMd: 8
  readonly property int spacingLg: 12
  readonly property int popupRadius: 10
  readonly property int statusIconSize: 20
  readonly property int statusIconPadding: 4

  // Typography
  readonly property int fontSizeSmall: 11
  readonly property int fontSizeNormal: 12

  // Motion, in milliseconds
  readonly property int motionFast: 140
  readonly property int motionMedium: 160
  readonly property int motionNormal: 180
}
