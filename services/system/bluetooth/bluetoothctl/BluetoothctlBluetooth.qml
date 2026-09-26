import QtQuick
import Quickshell.Io
import qs.services.system.bluetooth

Bluetooth {
  id: root

  property var knownDevices: []
  property var pairedAddresses: []
  property var connectedAddresses: []
  property string pendingPairAddress: ""

  function parseDevices(output) {
    const result = []
    const lines = output.trim().split("\n")
    for (let i = 0; i < lines.length; ++i) {
      const match = lines[i].match(/^Device\s+([0-9A-Fa-f:]{17})\s+(.+)$/)
      if (match) result.push({ address: match[1], name: match[2] })
    }
    return result
  }

  function parseAddresses(output) {
    const result = []
    const devices = root.parseDevices(output)
    for (let i = 0; i < devices.length; ++i) result.push(devices[i].address)
    return result
  }

  function rebuildDevices() {
    const result = []
    for (let i = 0; i < root.knownDevices.length; ++i) {
      const device = root.knownDevices[i]
      result.push({
        address: device.address,
        name: device.name,
        paired: root.pairedAddresses.indexOf(device.address) >= 0,
        connected: root.connectedAddresses.indexOf(device.address) >= 0
      })
    }
    result.sort((a, b) => Number(b.connected) - Number(a.connected)
      || Number(b.paired) - Number(a.paired) || a.name.localeCompare(b.name))
    root.devices = result
  }

  function refresh() {
    if (!statusProcess.running) statusProcess.running = true
    if (!devicesProcess.running) devicesProcess.running = true
    if (!pairedProcess.running) pairedProcess.running = true
    if (!connectedProcess.running) connectedProcess.running = true
  }

  function runAction(args) {
    if (actionProcess.running) return false
    root.error = ""
    actionProcess.command = ["bluetoothctl"].concat(args)
    actionProcess.running = true
    return true
  }

  function setPowered(enabled) {
    root.runAction(["power", enabled ? "on" : "off"])
  }

  function scan() {
    if (!root.powered || scanProcess.running) return
    root.error = ""
    scanProcess.running = true
  }

  function pair(address) {
    if (!address || !root.runAction(["pair", address])) return
    root.pendingPairAddress = address
  }

  function unpair(address) {
    if (address) root.runAction(["remove", address])
  }

  function connectDevice(address) {
    if (address) root.runAction(["connect", address])
  }

  function disconnectDevice(address) {
    if (address) root.runAction(["disconnect", address])
  }

  property Process statusProcess: Process {
    command: ["bluetoothctl", "show"]
    stdout: StdioCollector {
      onStreamFinished: root.powered = /Powered:\s+yes/.test(text)
    }
    stderr: StdioCollector {}
    onExited: exitCode => {
      root.available = exitCode === 0
      if (exitCode !== 0) {
        root.powered = false
        root.error = stderr.text.trim() || "bluetoothctl is unavailable"
      }
    }
  }

  property Process devicesProcess: Process {
    command: ["bluetoothctl", "devices"]
    stdout: StdioCollector {
      onStreamFinished: {
        root.knownDevices = root.parseDevices(text)
        root.rebuildDevices()
      }
    }
  }

  property Process pairedProcess: Process {
    command: ["bluetoothctl", "devices", "Paired"]
    stdout: StdioCollector {
      onStreamFinished: {
        root.pairedAddresses = root.parseAddresses(text)
        root.rebuildDevices()
      }
    }
  }

  property Process connectedProcess: Process {
    command: ["bluetoothctl", "devices", "Connected"]
    stdout: StdioCollector {
      onStreamFinished: {
        root.connectedAddresses = root.parseAddresses(text)
        root.rebuildDevices()
      }
    }
  }

  property Process scanProcess: Process {
    command: ["bluetoothctl", "--timeout", "8", "scan", "on"]
    stdout: StdioCollector {}
    stderr: StdioCollector {}
    onRunningChanged: root.scanning = running
    onExited: exitCode => {
      if (exitCode !== 0) root.error = stderr.text.trim() || "Bluetooth scan failed"
      root.refresh()
    }
  }

  property Process actionProcess: Process {
    stdout: StdioCollector {}
    stderr: StdioCollector {}
    onExited: exitCode => {
      const pairedAddress = root.pendingPairAddress
      root.pendingPairAddress = ""
      if (exitCode !== 0) {
        root.error = stderr.text.trim() || stdout.text.trim() || "Bluetooth operation failed"
        root.refresh()
      } else if (pairedAddress) {
        actionDelay.address = pairedAddress
        actionDelay.restart()
      } else {
        root.refresh()
      }
    }
  }

  property Timer actionDelay: Timer {
    property string address: ""
    interval: 250
    onTriggered: {
      const target = address
      address = ""
      root.connectDevice(target)
    }
  }

  property Timer autoRefreshTimer: Timer {
    interval: 5000
    running: true
    repeat: true
    onTriggered: root.refresh()
  }

  Component.onCompleted: root.refresh()
}
