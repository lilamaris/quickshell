import QtQuick
import Quickshell.Io
import qs.services.system.audio

Audio {
  id: root
  backendName: "PipeWire / WirePlumber"

  function parseStatus(output) {
    const outputs = []
    const inputs = []
    let section = ""
    const lines = output.split('\n')

    for (let i = 0; i < lines.length; ++i) {
      const line = lines[i]
      if (line.indexOf("Sinks:") >= 0) {
        section = "output"
        continue
      }
      if (line.indexOf("Sources:") >= 0) {
        section = "input"
        continue
      }
      if (line.indexOf("Filters:") >= 0 || line.indexOf("Streams:") >= 0
          || line.indexOf("Devices:") >= 0 || line.indexOf("Video") >= 0) {
        section = ""
        continue
      }
      if (!section) continue

      const match = line.match(/^\s*[│├└─\s]*([*]?)\s*(\d+)\.\s+(.+?)\s*$/)
      if (!match) continue

      const volumeMatch = match[3].match(/^(.*?)\s+\[vol:\s*([0-9.]+)(?:\s+(MUTED))?\]\s*$/)

      const device = {
        id: match[2],
        name: volumeMatch ? volumeMatch[1] : match[3],
        active: match[1] === "*",
        volume: volumeMatch ? Math.round(Number(volumeMatch[2]) * 100) : 0,
        muted: Boolean(volumeMatch && volumeMatch[3] === "MUTED")
      }
      if (section === "output") outputs.push(device)
      else inputs.push(device)
    }

    root.outputDevices = outputs
    root.inputDevices = inputs
    root.defaultOutputId = ""
    root.defaultInputId = ""

    for (let i = 0; i < outputs.length; ++i) {
      if (!outputs[i].active) continue
      root.defaultOutputId = outputs[i].id
      root.outputVolume = outputs[i].volume
      root.outputMuted = outputs[i].muted
      break
    }
    for (let i = 0; i < inputs.length; ++i) {
      if (!inputs[i].active) continue
      root.defaultInputId = inputs[i].id
      root.inputVolume = inputs[i].volume
      root.inputMuted = inputs[i].muted
      break
    }
  }

  function refresh() {
    if (!statusProcess.running) statusProcess.running = true
  }

  function setDefaultOutput(id) {
    if (!id || defaultProcess.running) return
    defaultProcess.command = ["wpctl", "set-default", id]
    defaultProcess.running = true
  }

  function setDefaultInput(id) {
    root.setDefaultOutput(id)
  }

  function setOutputVolume(volume) {
    if (outputVolumeProcess.running) return
    root.outputVolume = Math.max(0, Math.min(100, volume))
    outputVolumeProcess.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@",
                                   (root.outputVolume / 100).toFixed(2)]
    outputVolumeProcess.running = true
  }

  function setInputVolume(volume) {
    if (inputVolumeProcess.running) return
    root.inputVolume = Math.max(0, Math.min(100, volume))
    inputVolumeProcess.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SOURCE@",
                                  (root.inputVolume / 100).toFixed(2)]
    inputVolumeProcess.running = true
  }

  function toggleOutputMute() {
    if (muteProcess.running) return
    muteProcess.command = ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]
    muteProcess.running = true
  }

  function toggleInputMute() {
    if (muteProcess.running) return
    muteProcess.command = ["wpctl", "set-mute", "@DEFAULT_AUDIO_SOURCE@", "toggle"]
    muteProcess.running = true
  }

  property Process statusProcess: Process {
    command: ["wpctl", "status"]
    stderr: StdioCollector {}
    stdout: StdioCollector { onStreamFinished: root.parseStatus(text) }
    onExited: exitCode => {
      root.available = exitCode === 0
      root.error = exitCode === 0 ? "" : (stderr.text.trim() || "wpctl is unavailable")
    }
  }

  property Process defaultProcess: Process {
    onExited: root.refresh()
  }

  property Process outputVolumeProcess: Process {
    onExited: root.refresh()
  }

  property Process inputVolumeProcess: Process {
    onExited: root.refresh()
  }

  property Process muteProcess: Process {
    onExited: root.refresh()
  }

  property Timer autoRefreshTimer: Timer {
    interval: 3000
    running: true
    repeat: true
    onTriggered: root.refresh()
  }

  Component.onCompleted: root.refresh()
}
