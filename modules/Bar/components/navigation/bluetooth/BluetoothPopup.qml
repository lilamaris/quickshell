import QtQuick
import QtQuick.Controls
import qs.components.common
import qs.components.theme
import qs.services
import qs.services.system.bluetooth

Item {
  id: root

  readonly property Bluetooth bluetooth: BluetoothService.backend

  implicitWidth: 320
  implicitHeight: content.implicitHeight

  Column {
    id: content
    width: root.implicitWidth
    padding: 16
    spacing: Theme.spacingLg

    Row {
      width: 288
      height: 32
      spacing: Theme.spacingMd

      Text {
        width: parent.width - refreshButton.width - powerSwitch.width - parent.spacing * 2
        anchors.verticalCenter: parent.verticalCenter
        text: "Bluetooth"
        color: Theme.textHeading
        font.pixelSize: 16
        font.weight: Font.DemiBold
      }

      IconButton {
        id: refreshButton
        iconSource: AssetService.icon("refresh")
        iconSize: 16
        padding: 8
        accessibleName: "Refresh Bluetooth devices"
        enabled: root.bluetooth.available
        onClicked: root.bluetooth.refresh()
      }

      Switch {
        id: powerSwitch
        anchors.verticalCenter: parent.verticalCenter
        width: 48
        height: 28
        checked: root.bluetooth.powered
        enabled: root.bluetooth.available
        Accessible.name: "Bluetooth power"
        onToggled: root.bluetooth.setPowered(checked)

        indicator: Rectangle {
          width: 48
          height: 24
          y: (powerSwitch.height - height) / 2
          radius: height / 2
          color: powerSwitch.checked ? Theme.accent : Theme.buttonBackground
          opacity: powerSwitch.enabled ? 1 : 0.5

          Rectangle {
            x: powerSwitch.checked ? parent.width - width - 3 : 3
            anchors.verticalCenter: parent.verticalCenter
            width: 18
            height: 18
            radius: 9
            color: Theme.textPrimary

            Behavior on x {
              NumberAnimation { duration: Theme.motionFast }
            }
          }
        }

        contentItem: Item {}
      }
    }

    Rectangle {
      width: 288
      height: 68
      radius: Theme.popupRadius
      color: Theme.cardBackground

      Image {
        id: statusIcon
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        width: 24
        height: 24
        source: AssetService.icon(!root.bluetooth.powered
          ? "bluetooth-disabled" : root.bluetooth.connectedDeviceCount > 0
            ? "bluetooth-active" : "bluetooth")
        sourceSize.width: width
        sourceSize.height: height
      }

      Column {
        anchors.left: statusIcon.right
        anchors.leftMargin: 14
        anchors.right: scanButton.left
        anchors.rightMargin: Theme.spacingMd
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.spacingXs

        Text {
          width: parent.width
          text: !root.bluetooth.available ? "Bluetooth unavailable"
            : root.bluetooth.powered ? "Bluetooth is on" : "Bluetooth is off"
          color: Theme.textPrimary
          font.pixelSize: Theme.fontSizeNormal
          font.weight: Font.DemiBold
          elide: Text.ElideRight
        }

        Text {
          width: parent.width
          text: !root.bluetooth.powered ? "Turn on to connect devices"
            : root.bluetooth.connectedDeviceCount === 0 ? "No devices connected"
            : root.bluetooth.connectedDeviceCount + " connected"
          color: root.bluetooth.connectedDeviceCount > 0 ? Theme.textSuccess : Theme.textMuted
          font.pixelSize: Theme.fontSizeSmall
          elide: Text.ElideRight
        }
      }

      TextButton {
        id: scanButton
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        width: 76
        text: root.bluetooth.scanning ? "Scanning…" : "Scan"
        enabled: root.bluetooth.available && root.bluetooth.powered && !root.bluetooth.scanning
        onClicked: root.bluetooth.scan()
      }
    }

    Rectangle {
      visible: !root.bluetooth.available || root.bluetooth.error !== ""
      width: 288
      implicitHeight: errorText.implicitHeight + 16
      radius: Theme.spacingMd
      color: Theme.accentBackground

      Text {
        id: errorText
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Theme.spacingMd
        anchors.verticalCenter: parent.verticalCenter
        text: root.bluetooth.error || "Bluetooth backend is unavailable"
        color: Theme.textError
        font.pixelSize: Theme.fontSizeSmall
        wrapMode: Text.Wrap
      }
    }

    Row {
      width: 288
      height: 16

      Text {
        width: parent.width - deviceCount.width
        text: "Devices"
        color: Theme.textMuted
        font.pixelSize: Theme.fontSizeSmall
        font.weight: Font.DemiBold
      }

      Text {
        id: deviceCount
        text: String(deviceList.count)
        color: Theme.textMuted
        font.pixelSize: Theme.fontSizeSmall
      }
    }

    Text {
      visible: !root.bluetooth.powered || deviceList.count === 0
      width: 288
      text: !root.bluetooth.powered ? "Turn on Bluetooth to see devices"
        : root.bluetooth.scanning ? "Looking for nearby devices…"
        : "No Bluetooth devices found"
      color: Theme.textMuted
      font.pixelSize: Theme.fontSizeNormal
    }

    ListView {
      id: deviceList
      visible: root.bluetooth.powered && count > 0
      width: 288
      height: Math.min(count * 54 + Math.max(0, count - 1) * spacing,
                       root.bluetooth.error ? 170 : 224)
      clip: true
      spacing: Theme.spacingSm
      model: root.bluetooth.devices
      ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

      delegate: PopupListItem {
        required property var modelData
        width: deviceList.width
        iconSource: AssetService.icon(modelData.connected
          ? "bluetooth-active" : "bluetooth")
        title: modelData.name
        subtitle: modelData.connected ? "Connected"
          : modelData.paired ? "Paired" : modelData.address
        detail: modelData.connected ? "Disconnect"
          : modelData.paired ? "Connect" : "Pair"
        detailIsAction: true
        selected: modelData.connected
        enabled: root.bluetooth.available && root.bluetooth.powered
        onClicked: {
          if (modelData.connected)
            root.bluetooth.disconnectDevice(modelData.address)
          else if (modelData.paired)
            root.bluetooth.connectDevice(modelData.address)
          else
            root.bluetooth.pair(modelData.address)
        }
      }
    }
  }
}
