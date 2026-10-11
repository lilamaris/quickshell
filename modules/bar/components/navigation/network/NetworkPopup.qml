import QtQuick
import QtQuick.Controls
import qs.components.common
import qs.components.theme
import qs.services
import qs.services.system.network

Item {
  id: root

  signal keyboardFocusRequested()

  property var selectedNetwork: null
  readonly property bool passwordVisible: selectedNetwork !== null
    && NetworkService.wifi.passwordRequiredFor === selectedNetwork.ssid
    && !(NetworkService.wifi.connected && NetworkService.wifi.connection === selectedNetwork.ssid)

  onPasswordVisibleChanged: {
    if (!passwordField) return
    if (passwordVisible) {
      root.keyboardFocusRequested()
      Qt.callLater(() => passwordField.forceActiveFocus())
    }
    else passwordField.clear()
  }

  function connectSelectedNetwork() {
    if (!root.selectedNetwork || !passwordField.text || NetworkService.wifi.isConnecting) return
    NetworkService.wifi.connectNetwork(root.selectedNetwork.ssid, passwordField.text)
  }

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
        width: parent.width - refreshButton.width - parent.spacing
        anchors.verticalCenter: parent.verticalCenter
        text: "Wi-Fi"
        color: Theme.textHeading
        font.pixelSize: 16
        font.weight: Font.DemiBold
      }

      IconButton {
        id: refreshButton
        iconSource: AssetService.icon("refresh")
        iconSize: 16
        padding: 8
        accessibleName: NetworkService.wifi.isForceRefreshing ? "Scanning networks" : "Rescan networks"
        enabled: NetworkService.wifi.enabled && !NetworkService.wifi.isForceRefreshing
        onClicked: NetworkService.wifi.refresh(true)
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
        source: AssetService.icon(NetworkService.wifi.connected
          ? "network-wireless" : "network-wireless-offline")
        sourceSize.width: width
        sourceSize.height: height
      }

      Column {
        anchors.left: statusIcon.right
        anchors.leftMargin: 14
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.spacingXs

        Text {
          width: parent.width
          text: NetworkService.wifi.connected ? NetworkService.wifi.connection
            : !NetworkService.wifi.available ? "Wi-Fi unavailable"
            : !NetworkService.wifi.enabled ? "Wi-Fi off" : "Not connected"
          color: Theme.textPrimary
          font.pixelSize: Theme.fontSizeNormal
          font.weight: Font.DemiBold
          elide: Text.ElideRight
        }

        Text {
          width: parent.width
          text: NetworkService.wifi.connected
            ? "Connected · " + NetworkService.wifi.signal + "% signal"
            : NetworkService.wifi.enabled ? "Choose a network to get online"
            : "Enable Wi-Fi in system settings"
          color: NetworkService.wifi.connected ? Theme.textSuccess : Theme.textMuted
          font.pixelSize: Theme.fontSizeSmall
          elide: Text.ElideRight
        }
      }
    }

    Rectangle {
      visible: NetworkService.wifi.connectionError !== ""
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
        text: NetworkService.wifi.connectionError
        color: Theme.textError
        font.pixelSize: Theme.fontSizeSmall
        wrapMode: Text.Wrap
      }
    }

    Row {
      width: 288
      height: 16

      Text {
        width: parent.width - networkCount.width
        text: "Available networks"
        color: Theme.textMuted
        font.pixelSize: Theme.fontSizeSmall
        font.weight: Font.DemiBold
      }

      Text {
        id: networkCount
        text: String(networkList.count)
        color: Theme.textMuted
        font.pixelSize: Theme.fontSizeSmall
      }
    }

    Text {
      visible: networkList.count === 0
      width: 288
      text: NetworkService.wifi.isForceRefreshing
        ? "Looking for nearby networks…"
        : NetworkService.wifi.enabled ? "No networks found" : "No networks available"
      color: Theme.textMuted
      font.pixelSize: Theme.fontSizeNormal
    }

    ListView {
      id: networkList
      visible: count > 0
      width: 288
      height: Math.min(count * 54 + Math.max(0, count - 1) * spacing,
                       root.passwordVisible ? 130 : 200)
      clip: true
      spacing: Theme.spacingSm
      model: NetworkService.wifi.availableNetworks

      delegate: PopupListItem {
        required property var modelData
        width: networkList.width
        iconSource: AssetService.icon("network-wireless")
        title: modelData.ssid
        subtitle: modelData.active ? "Connected"
          : modelData.known ? "Saved network"
          : modelData.secured ? "Secured network" : "Open network"
        detail: modelData.signal + "%"
        selected: modelData.active || (root.passwordVisible
          && root.selectedNetwork.ssid === modelData.ssid)
        enabled: NetworkService.wifi.enabled && !NetworkService.wifi.isConnecting
        onClicked: {
          if (modelData.active) return
          root.selectedNetwork = modelData
          passwordField.text = ""
          NetworkService.wifi.connectNetwork(modelData.ssid, "")
        }
      }
    }

    Text {
      visible: root.passwordVisible
      width: 288
      text: root.selectedNetwork ? "Password for " + root.selectedNetwork.ssid : ""
      color: Theme.textPrimary
      font.pixelSize: Theme.fontSizeSmall
      elide: Text.ElideRight
    }

    TextField {
      id: passwordField
      visible: root.passwordVisible
      width: 288
      height: 36
      placeholderText: "Network password"
      echoMode: TextInput.Password
      enabled: !NetworkService.wifi.isConnecting
      color: Theme.textPrimary
      placeholderTextColor: Theme.textMuted
      font.pixelSize: Theme.fontSizeNormal
      leftPadding: Theme.spacingLg
      rightPadding: Theme.spacingLg
      onAccepted: root.connectSelectedNetwork()

      background: Rectangle {
        radius: Theme.spacingMd
        color: Theme.buttonBackground
        border.width: passwordField.activeFocus ? 1 : 0
        border.color: Theme.accent
      }
    }

    TextButton {
      visible: root.passwordVisible
      width: 288
      emphasized: true
      text: NetworkService.wifi.isConnecting ? "Connecting…" : "Connect"
      enabled: passwordField.text.length > 0 && !NetworkService.wifi.isConnecting
      onClicked: root.connectSelectedNetwork()
    }
  }
}
