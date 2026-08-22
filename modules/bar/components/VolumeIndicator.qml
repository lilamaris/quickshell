import QtQuick
import Quickshell
import qs.components.common

Item {
  id: root

  implicitWidth: wifiButton.implicitWidth
  implicitHeight: wifiButton.implicitHeight

  TextButton {
    id: wifiButton

    text: "Volume"
    foregroundColor: "#FF0000"
    backgroundColor: "#00FF00"
  }
}
