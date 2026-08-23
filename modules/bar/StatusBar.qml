import Quickshell
import QtQuick

import qs.modules.bar.components

Variants {
  model: Quickshell.screens

  PanelWindow {
    required property var modelData
    screen: modelData

    anchors {
      top: Config.position !== "bottom"
      bottom: Config.position !== "top"
      left: Config.position !== "right"
      right: Config.position !== "left"
    }

    implicitHeight: 28
    implicitWidth: 52

    color: "#111827"

    Navigation {}
  }
}
