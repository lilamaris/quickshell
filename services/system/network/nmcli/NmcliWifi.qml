import QtQuick
import Quickshell.Io
import qs.services.system.network

Wifi {
  id: root

  function splitNmcliLine(line) {
    const fields = []
    let field = ""
    let escaped = false

    for (let i = 0; i < line.length; ++i) {
      const character = line[i]
      if (escaped) {
        field += character
        escaped = false
      } else if (character === "\\") {
        escaped = true
      } else if (character === ":") {
        fields.push(field)
        field = ""
      } else {
        field += character
      }
    }
    if (escaped) field += "\\"
    fields.push(field)
    return fields
  }

  function updateConnectionState(output) {
    root.connected = false
    root.device = "Unknown Device"
    root.connection = "Not connected"
    root.signal = 0

    const lines = output.trim().split('\n')
    for (let i = 0; i < lines.length; ++i) {
      const parts = root.splitNmcliLine(lines[i])
      if (parts.length < 4 || parts[0] === "lo" || parts[1] !== "wifi") continue

      if (root.device === "Unknown Device") root.device = parts[0]
      if (parts[2] !== "connected") continue

      root.connected = true
      root.device = parts[0]
      root.connection = parts.slice(3).join(":")
      return
    }
  }

  function updateAvailableNetworks(output) {
    const networksBySsid = ({})
    const lines = output.trim().split('\n')

    for (let i = 0; i < lines.length; ++i) {
      const parts = root.splitNmcliLine(lines[i])
      if (parts.length < 5 || !parts[1]) continue

      const network = {
        active: parts[0] === "yes" || parts[0] === "*",
        ssid: parts[1],
        signal: Number(parts[2]) || 0,
        security: parts[3] || "",
        bssid: parts.slice(4).join(":"),
        secured: Boolean(parts[3] && parts[3] !== "--")
      }
      const previous = networksBySsid[network.ssid]
      if (!previous || network.active || network.signal > previous.signal)
        networksBySsid[network.ssid] = network
    }

    const networks = Object.keys(networksBySsid).map(ssid => networksBySsid[ssid])
    networks.sort((a, b) => Number(b.active) - Number(a.active) || b.signal - a.signal)
    root.availableNetworks = networks

    for (let i = 0; i < networks.length; ++i) {
      if (networks[i].active) {
        root.signal = networks[i].signal
        break
      }
    }
  }

  property Process statusProcess: Process {
    command: ["nmcli", "-t", "-f", "DEVICE,TYPE,STATE,CONNECTION", "device"]

    stdout: StdioCollector {
      onStreamFinished: root.updateConnectionState(text)
    }
  }

  function refresh(force) {
    if (!statusProcess.running) statusProcess.running = true
    if (!scanProcess.running) {
      root.isForceRefreshing = Boolean(force)
      scanProcess.command = ["nmcli", "-t", "-f", "IN-USE,SSID,SIGNAL,SECURITY,BSSID",
                             "device", "wifi", "list", "--rescan", force ? "yes" : "auto"]
      scanProcess.running = true
    }
  }

  function connectNetwork(ssid, password) {
    if (!ssid || connectProcess.running) return
    root.connectionError = ""
    root.isConnecting = true
    const args = ["nmcli", "device", "wifi", "connect", ssid]
    if (password) args.push("password", password)
    if (root.device !== "Unknown Device") args.push("ifname", root.device)
    connectProcess.command = args
    connectProcess.running = true
  }

  property Process scanProcess: Process {
    stdout: StdioCollector {
      onStreamFinished: root.updateAvailableNetworks(text)
    }
    onExited: exitCode => {
      root.isForceRefreshing = false
      if (exitCode !== 0) root.connectionError = "Wi-Fi scan failed"
    }
  }

  property Process connectProcess: Process {
    stderr: StdioCollector {}
    onExited: exitCode => {
      root.isConnecting = false
      if (exitCode === 0) {
        root.connectionError = ""
        root.refresh(true)
      } else {
        root.connectionError = stderr.text.trim() || "Unable to connect to Wi-Fi"
      }
    }
  }

  property Timer autoRefreshTimer: Timer {
    interval: 5000
    running: true
    repeat: true
    onTriggered: root.refresh()
  }

  Component.onCompleted: root.refresh(true)
}
