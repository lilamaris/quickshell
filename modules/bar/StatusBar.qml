import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs.services.system.network
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

    FlexboxLayout {
      id: layout
      anchors.fill: parent

      direction: FlexboxLayout.Row
      alignItems: FlexboxLayout.AlignCenter
      justifyContent: FlexboxLayout.JustifyCenter

      NetworkIndicator {}

      VolumeIndicator {}
    }
  }
}
