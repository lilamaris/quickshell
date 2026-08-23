import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.components.common
import qs.services.system.audio
import qs.services.system.network

Item {
  id: root

  anchors.fill: parent

  property Item activeAnchor: null
  property Component activeContent: null

  function setContent(anchor, content) {
    root.activeAnchor = anchor
    root.activeContent = content
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
          }
        }
      }

      content: Component {
        NetworkPopup {}
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
          }
        }
      }

      content: Component {
        VolumePopup {}
      }
    }
  }

  PopupWindow {
    visible: contentLoader.status === Loader.Ready
      && contentLoader.item !== null

    color: "transparent"

    implicitWidth: contentLoader.width
    implicitHeight: contentLoader.height

    anchor {
      item: root.activeAnchor
      rect.x: root.activeAnchor.width - implicitWidth
      rect.y: root.activeAnchor.height + 6
    }

    Rectangle {
      anchors.fill: parent

      radius: 10
      color: "#181825"

      Loader {
        id: contentLoader
        sourceComponent: root.activeContent
      }
    }
  }
}
