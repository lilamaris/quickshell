import QtQuick
import QtQuick.Controls
import qs.services.system.network

Item {
  id: root

  implicitWidth: 280
  implicitHeight: content.implicitHeight

  Column {
    id: content

    width: 280
    padding: 12
    spacing: 8

    Row {
      spacing: 8

      Button {
        text: NetworkService.wifi.isForceRefreshing ? "Scanning…" : "Rescan"
        enabled: !NetworkService.wifi.isForceRefreshing
        onClicked: NetworkService.wifi.refresh(true)
      }

      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: NetworkService.wifi.connected
          ? NetworkService.wifi.connection + "  " + NetworkService.wifi.signal + "%"
          : "Not connected"
        color: "white"
        elide: Text.ElideRight
        width: 170
      }
    }

    Text {
      visible: NetworkService.wifi.connectionError !== ""
      width: 256
      wrapMode: Text.Wrap
      text: NetworkService.wifi.connectionError
      color: "#f38ba8"
      font.pixelSize: 11
    }

    ListView {
      id: networkList
      width: 256
      height: Math.min(count * 36 + Math.max(0, count - 1) * spacing, 240)
      clip: true
      spacing: 4
      model: NetworkService.wifi.availableNetworks

      delegate: Button {
        required property var modelData
        width: networkList.width
        text: (modelData.active ? "✓ " : "") + modelData.ssid
          + "  " + modelData.signal + "%" + (modelData.secured ? "  🔒" : "")
        enabled: !NetworkService.wifi.isConnecting
        onClicked: {
          content.selectedNetwork = modelData
          passwordField.text = ""
          if (!modelData.secured || modelData.active)
            NetworkService.wifi.connectNetwork(modelData.ssid, "")
          else
            passwordField.forceActiveFocus()
        }
      }
    }

    property var selectedNetwork: null

    Text {
      visible: content.selectedNetwork && content.selectedNetwork.secured
        && !content.selectedNetwork.active
      text: content.selectedNetwork ? "Password for " + content.selectedNetwork.ssid : ""
      color: "#cdd6f4"
    }

    TextField {
      id: passwordField
      visible: content.selectedNetwork && content.selectedNetwork.secured
        && !content.selectedNetwork.active
      width: 256
      placeholderText: "Wi-Fi password"
      echoMode: TextInput.Password
      enabled: !NetworkService.wifi.isConnecting
      onAccepted: connectButton.clicked()
    }

    Button {
      id: connectButton
      visible: passwordField.visible
      width: 256
      text: NetworkService.wifi.isConnecting ? "Connecting…" : "Connect"
      enabled: passwordField.text.length > 0 && !NetworkService.wifi.isConnecting
      onClicked: NetworkService.wifi.connectNetwork(content.selectedNetwork.ssid, passwordField.text)
    }
  }
}
