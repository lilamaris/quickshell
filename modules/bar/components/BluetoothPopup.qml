import QtQuick
import QtQuick.Controls
import qs.components.theme
import qs.services.system.bluetooth

Item {
  id: root

  readonly property var bluetooth: BluetoothService.backend

  implicitWidth: 320
  implicitHeight: content.implicitHeight

  Column {
    id: content
    width: 320
    padding: Theme.spacingLg
    spacing: Theme.spacingMd

    Row {
      width: 296
      spacing: Theme.spacingMd

      Text {
        anchors.verticalCenter: parent.verticalCenter
        width: 190
        text: "Bluetooth"
        color: Theme.textHeading
        font.bold: true
      }

      Switch {
        checked: root.bluetooth.powered
        enabled: root.bluetooth.available
        text: checked ? "On" : "Off"
        onToggled: root.bluetooth.setPowered(checked)
      }
    }

    Row {
      spacing: Theme.spacingMd

      Button {
        text: root.bluetooth.scanning ? "Scanning…" : "Scan for devices"
        enabled: root.bluetooth.available && root.bluetooth.powered && !root.bluetooth.scanning
        onClicked: root.bluetooth.scan()
      }

      Button {
        text: "↻"
        enabled: root.bluetooth.available
        onClicked: root.bluetooth.refresh()
      }
    }

    Text {
      visible: !root.bluetooth.available || root.bluetooth.error !== ""
      width: 296
      wrapMode: Text.Wrap
      text: root.bluetooth.error || "Bluetooth backend is unavailable"
      color: Theme.textError
      font.pixelSize: Theme.fontSizeSmall
    }

    Text {
      visible: root.bluetooth.powered && root.bluetooth.devices.length === 0
      width: 296
      text: root.bluetooth.scanning ? "Looking for nearby devices…" : "No Bluetooth devices found"
      color: Theme.textMuted
    }

    ListView {
      id: deviceList
      visible: root.bluetooth.powered
      width: 296
      height: Math.min(count * 48 + Math.max(0, count - 1) * spacing, 288)
      clip: true
      spacing: Theme.spacingSm
      model: root.bluetooth.devices

      delegate: Row {
        required property var modelData
        width: deviceList.width
        height: 48
        spacing: 6

        Column {
          anchors.verticalCenter: parent.verticalCenter
          width: 184
          spacing: Theme.spacingXs

          Text {
            width: parent.width
            text: modelData.name
            color: Theme.textPrimary
            elide: Text.ElideRight
          }

          Text {
            width: parent.width
            text: modelData.connected ? "Connected"
              : modelData.paired ? "Paired" : modelData.address
            color: modelData.connected ? Theme.textSuccess : Theme.textMuted
            font.pixelSize: Theme.fontSizeSmall
            elide: Text.ElideRight
          }
        }

        Button {
          anchors.verticalCenter: parent.verticalCenter
          width: 106
          text: modelData.connected ? "Disconnect"
            : modelData.paired ? "Connect" : "Pair"
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
}
