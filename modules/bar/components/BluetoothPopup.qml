import QtQuick
import QtQuick.Controls
import qs.services.system.bluetooth

Item {
  id: root

  readonly property var bluetooth: BluetoothService.backend

  implicitWidth: 320
  implicitHeight: content.implicitHeight

  Column {
    id: content
    width: 320
    padding: 12
    spacing: 8

    Row {
      width: 296
      spacing: 8

      Text {
        anchors.verticalCenter: parent.verticalCenter
        width: 190
        text: "Bluetooth"
        color: "#cdd6f4"
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
      spacing: 8

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
      color: "#f38ba8"
      font.pixelSize: 11
    }

    Text {
      visible: root.bluetooth.powered && root.bluetooth.devices.length === 0
      width: 296
      text: root.bluetooth.scanning ? "Looking for nearby devices…" : "No Bluetooth devices found"
      color: "#a6adc8"
    }

    ListView {
      id: deviceList
      visible: root.bluetooth.powered
      width: 296
      height: Math.min(count * 48 + Math.max(0, count - 1) * spacing, 288)
      clip: true
      spacing: 4
      model: root.bluetooth.devices

      delegate: Row {
        required property var modelData
        width: deviceList.width
        height: 48
        spacing: 6

        Column {
          anchors.verticalCenter: parent.verticalCenter
          width: 184
          spacing: 2

          Text {
            width: parent.width
            text: modelData.name
            color: "white"
            elide: Text.ElideRight
          }

          Text {
            width: parent.width
            text: modelData.connected ? "Connected"
              : modelData.paired ? "Paired" : modelData.address
            color: modelData.connected ? "#a6e3a1" : "#a6adc8"
            font.pixelSize: 11
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
