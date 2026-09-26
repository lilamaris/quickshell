import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.components.common
import qs.services.system.audio
import qs.services.system.bluetooth
import qs.services.system.network

Item {
  id: root

  anchors.fill: parent

  property Item activeAnchor: null
  property Component activeContent: null
  property bool popupOpen: false
  property bool hasPopupPosition: false
  property bool animatePopupPosition: false
  property real popupWidth: 0
  property real popupX: 0

  Behavior on popupX {
    enabled: root.animatePopupPosition

    NumberAnimation {
      duration: 180
      easing.type: Easing.OutCubic
    }
  }

  function setContent(anchor, content) {
    closeTimer.stop()
    root.activeAnchor = anchor
    root.activeContent = content
    root.popupOpen = true
  }

  function clearContent(anchor) {
    if (root.activeAnchor !== anchor) return
    root.popupOpen = false
    closeTimer.restart()
  }

  function keepContentOpen() {
    if (root.activeContent === null) return
    closeTimer.stop()
    root.popupOpen = true
  }

  function positionPopup() {
    if (!root.activeAnchor || !contentLoader.item) return

    const width = contentLoader.item.implicitWidth
    const anchorRight = root.activeAnchor.mapToItem(root, root.activeAnchor.width, 0).x
    const targetX = anchorRight - width

    root.animatePopupPosition = root.hasPopupPosition
    root.popupWidth = width
    root.popupX = targetX
    root.hasPopupPosition = true
  }

  Timer {
    id: closeTimer
    interval: 160
    onTriggered: {
      if (!root.popupOpen) {
        root.activeContent = null
        root.hasPopupPosition = false
        root.animatePopupPosition = false
        root.popupWidth = 0
      }
    }
  }

  FlexboxLayout {
    anchors.fill: parent

    direction: FlexboxLayout.Row
    alignItems: FlexboxLayout.AlignCenter
    justifyContent: FlexboxLayout.JustifyCenter

    NavigationItem {
      id: network

      indicator: Component {
        IconButton {
          iconSource: Quickshell.iconPath(NetworkService.wifi.connected
            ? "network-wireless"
            : "network-wireless-offline")
          iconSize: 18
          padding: 5
          backgroundColor: "#00FF00"
          accessibleName: NetworkService.wifi.connected
            ? "Wi-Fi: " + NetworkService.wifi.connection
            : "Wi-Fi disconnected"

          onHoveredChanged: {
            if (hovered)
              setContent(network, network.content)
            else
              clearContent(network)
          }
        }
      }

      content: Component {
        NetworkPopup {}
      }
    }

    NavigationItem {
      id: bluetooth

      indicator: Component {
        IconButton {
          iconSource: Quickshell.iconPath(!BluetoothService.backend.powered
            ? "bluetooth-disabled"
            : BluetoothService.backend.connectedDeviceCount > 0
              ? "bluetooth-active" : "bluetooth")
          iconSize: 18
          padding: 5
          backgroundColor: "#00FF00"
          accessibleName: !BluetoothService.backend.available
            ? "Bluetooth unavailable"
            : !BluetoothService.backend.powered
              ? "Bluetooth off"
              : BluetoothService.backend.connectedDeviceCount > 0
                ? "Bluetooth connected" : "Bluetooth on"

          onHoveredChanged: {
            if (hovered)
              setContent(bluetooth, bluetooth.content)
            else
              clearContent(bluetooth)
          }
        }
      }

      content: Component {
        BluetoothPopup {}
      }
    }

    NavigationItem {
      id: volume

      indicator: Component {
        IconButton {
          iconSource: Quickshell.iconPath(AudioService.backend.outputMuted
            || AudioService.backend.outputVolume === 0
              ? "audio-volume-muted"
              : AudioService.backend.outputVolume < 34
                ? "audio-volume-low"
                : AudioService.backend.outputVolume < 67
                  ? "audio-volume-medium"
                  : "audio-volume-high")
          iconSize: 18
          padding: 5
          backgroundColor: "#00FF00"
          accessibleName: AudioService.backend.outputMuted
            ? "Audio muted"
            : "Volume " + Math.round(AudioService.backend.outputVolume) + "%"

          onHoveredChanged: {
            if (hovered)
              setContent(volume, volume.content)
            else
              clearContent(volume)
          }
        }
      }

      content: Component {
        VolumePopup {}
      }
    }
  }

  PopupWindow {
    id: popupWindow

    visible: root.activeContent !== null && root.popupWidth > 0

    color: "transparent"

    implicitWidth: root.popupWidth
    implicitHeight: contentLoader.height + 6

    anchor {
      item: root
      rect.x: root.popupX
      rect.y: root.height
    }

    Item {
      anchors.fill: parent

      HoverHandler {
        onHoveredChanged: {
          if (hovered)
            root.keepContentOpen()
          else
            root.clearContent(root.activeAnchor)
        }
      }

      Rectangle {
        y: 6
        width: parent.width
        height: parent.height - y

        radius: 10
        color: "#181825"
        opacity: root.popupOpen ? 1 : 0
        transform: Translate {
          y: root.popupOpen ? 0 : -4

          Behavior on y {
            NumberAnimation {
              duration: 160
              easing.type: Easing.OutCubic
            }
          }
        }

        Behavior on opacity {
          NumberAnimation {
            duration: 140
            easing.type: Easing.OutCubic
          }
        }

        Loader {
          id: contentLoader
          sourceComponent: root.activeContent
          onLoaded: root.positionPopup()
        }
      }
    }
  }
}
