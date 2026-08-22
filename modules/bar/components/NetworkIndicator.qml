import QtQuick
import QtQuick.Controls
import Quickshell
import qs.components.common
import qs.services.system.network

Item {
  id: root

  implicitWidth: wifiButton.implicitWidth
  implicitHeight: wifiButton.implicitHeight

  TextButton {
    id: wifiButton

    text: "Wi-Fi"
    foregroundColor: "#FF0000"
    backgroundColor: "#00FF00"

    onHoverChanged: {
      wifiPopup.visible = !wifiPopup.visible
    }
  }

  PopupWindow {
    id: wifiPopup

    visible: false

    color: "transparent"

    anchor {
      item: wifiButton

      rect.x: wifiButton.width - implicitWidth
      rect.y: wifiButton.height + 6
    }
    implicitWidth: 280
    implicitHeight: popupContent.implicitHeight

    Rectangle {
      anchors.fill: parent

      radius: 10
      color: "#181825"

      Column {
        id: popupContent

        width: parent.width
        padding: 12

        Button {
          text: "Force Refresh"

          onClicked: NetworkService.wifi.refresh(true)
        }

        Text {
          text: NetworkService.wifi.isForceRefreshing
          ? "Refreshing"
          : NetworkService.wifi.device
          color: "gray"
          font.bold: true
          font.pixelSize: 12
        }

        Text {
          text: NetworkService.wifi.isForceRefreshing
          ? "Refreshing"
          : NetworkService.wifi.connection
          color: "white"
          font.pixelSize: 16
        }
      }
    }
  }
}
