import QtQuick
import Quickshell.Networking
import qs.services.system.network

Wifi {
  id: root

  readonly property var wifiDevices: Networking.devices.values.filter(device =>
    device.type === DeviceType.Wifi)
  readonly property var wifiDevice: wifiDevices.find(device => device.connected)
    || wifiDevices[0] || null
  readonly property var connectedNetwork: wifiDevice
    ? wifiDevice.networks.values.find(network => network.connected) || null : null
  property var pendingNetwork: null
  property string pendingSsid: ""
  property bool usedPsk: false

  available: Networking.backend === NetworkBackendType.NetworkManager && wifiDevice !== null
  enabled: available && Networking.wifiEnabled && Networking.wifiHardwareEnabled
  device: wifiDevice ? wifiDevice.name : "Unknown Device"
  connected: connectedNetwork !== null
  connection: connectedNetwork ? connectedNetwork.name : "Not connected"
  signal: connectedNetwork ? Math.round(connectedNetwork.signalStrength * 100) : 0
  availableNetworks: root.networkList()

  function networkList() {
    if (!root.enabled || !root.wifiDevice) return []

    const byName = ({})
    for (const network of root.wifiDevice.networks.values) {
      if (!network.name) continue
      const item = {
        ssid: network.name,
        active: network.connected,
        signal: Math.round(network.signalStrength * 100),
        secured: network.security !== WifiSecurityType.Open,
        known: network.known
      }
      const previous = byName[item.ssid]
      if (!previous || item.active || (!previous.active && item.signal > previous.signal))
        byName[item.ssid] = item
    }

    const networks = Object.keys(byName).map(name => byName[name])
    networks.sort((a, b) => Number(b.active) - Number(a.active) || b.signal - a.signal)
    return networks
  }

  function supportsPsk(network) {
    return network.security === WifiSecurityType.WpaPsk
      || network.security === WifiSecurityType.Wpa2Psk
      || network.security === WifiSecurityType.Sae
  }

  function findNetwork(ssid) {
    if (!root.wifiDevice) return null
    const matches = root.wifiDevice.networks.values.filter(network => network.name === ssid)
    matches.sort((a, b) => Number(b.connected) - Number(a.connected)
      || b.signalStrength - a.signalStrength)
    return matches[0] || null
  }

  function refresh(force) {
    if (!root.enabled || !root.wifiDevice || !force || root.isForceRefreshing) return
    root.isForceRefreshing = true
    root.wifiDevice.scannerEnabled = false
    Qt.callLater(() => {
      if (root.wifiDevice && root.enabled) root.wifiDevice.scannerEnabled = true
    })
    scanFeedbackTimer.restart()
  }

  function connectNetwork(ssid, password) {
    if (!root.enabled || root.isConnecting) return
    const network = root.findNetwork(ssid)
    if (!network) {
      root.connectionError = "Network is no longer available"
      return
    }
    if (network.connected) return

    root.connectionError = ""
    if (!password) root.passwordRequiredFor = ""
    if (!password && !network.known && root.supportsPsk(network)) {
      root.passwordRequiredFor = ssid
      return
    }
    if (password && !root.supportsPsk(network)) {
      root.connectionError = "This network does not support password-only connection"
      return
    }

    root.pendingNetwork = network
    root.pendingSsid = ssid
    root.usedPsk = password !== ""
    root.isConnecting = true
    connectionTimeout.restart()
    if (password) network.connectWithPsk(password)
    else network.connect()
  }

  function finishConnection() {
    connectionTimeout.stop()
    disconnectSettled.stop()
    root.isConnecting = false
    root.pendingNetwork = null
    root.pendingSsid = ""
    root.usedPsk = false
  }

  function failureMessage(reason) {
    switch (reason) {
    case ConnectionFailReason.WifiNetworkLost:
      return "Network is no longer available"
    case ConnectionFailReason.WifiAuthTimeout:
      return "Network authentication timed out"
    case ConnectionFailReason.WifiClientDisconnected:
      return "Disconnected while connecting"
    default:
      return "Unable to connect to network"
    }
  }

  onWifiDevicesChanged: {
    for (const device of wifiDevices) device.scannerEnabled = root.enabled
  }

  onEnabledChanged: {
    for (const device of wifiDevices) device.scannerEnabled = root.enabled
  }

  property Connections pendingConnection: Connections {
    target: root.pendingNetwork
    ignoreUnknownSignals: true

    function onConnectedChanged() {
      if (!root.pendingNetwork || !root.pendingNetwork.connected) return
      root.passwordRequiredFor = ""
      root.connectionError = ""
      root.finishConnection()
    }

    function onStateChanged() {
      if (root.pendingNetwork && root.pendingNetwork.state === ConnectionState.Disconnected)
        disconnectSettled.restart()
    }

    function onConnectionFailed(reason) {
      if (reason === ConnectionFailReason.NoSecrets && root.pendingNetwork
          && root.supportsPsk(root.pendingNetwork)) {
        root.passwordRequiredFor = root.pendingSsid
        root.connectionError = root.usedPsk ? "Incorrect password or missing credentials" : ""
      } else if (reason === ConnectionFailReason.NoSecrets) {
        root.connectionError = "This network requires additional authentication"
      } else {
        root.connectionError = root.failureMessage(reason)
      }
      root.finishConnection()
    }
  }

  property Timer disconnectSettled: Timer {
    interval: 1000
    onTriggered: {
      if (!root.isConnecting || !root.pendingNetwork || root.pendingNetwork.connected) return
      root.connectionError = "Unable to connect to network"
      root.finishConnection()
    }
  }

  property Timer connectionTimeout: Timer {
    interval: 25000
    onTriggered: {
      root.connectionError = "Connection timed out"
      root.finishConnection()
    }
  }

  property Timer scanFeedbackTimer: Timer {
    interval: 2000
    onTriggered: root.isForceRefreshing = false
  }
}
