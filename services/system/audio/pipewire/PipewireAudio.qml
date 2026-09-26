import QtQuick
import Quickshell.Services.Pipewire
import qs.services.system.audio

Audio {
  id: root

  backendName: "PipeWire"
  available: Pipewire.ready
  error: Pipewire.ready ? "" : "PipeWire is unavailable"

  readonly property var outputNodes: Pipewire.nodes.values.filter(node =>
    node.audio && !node.isStream && node.isSink)
  readonly property var inputNodes: Pipewire.nodes.values.filter(node =>
    node.audio && !node.isStream && !node.isSink)

  // Audio properties are only valid on nodes bound by a tracker.
  property PwObjectTracker tracker: PwObjectTracker {
    objects: root.outputNodes.concat(root.inputNodes)
  }

  outputDevices: outputNodes.map(node => ({
    id: String(node.id),
    name: node.description || node.nickname || node.name,
    active: node === Pipewire.defaultAudioSink
  }))
  inputDevices: inputNodes.map(node => ({
    id: String(node.id),
    name: node.description || node.nickname || node.name,
    active: node === Pipewire.defaultAudioSource
  }))

  defaultOutputId: Pipewire.defaultAudioSink ? String(Pipewire.defaultAudioSink.id) : ""
  defaultInputId: Pipewire.defaultAudioSource ? String(Pipewire.defaultAudioSource.id) : ""
  outputVolume: Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.ready
    ? Pipewire.defaultAudioSink.audio.volume * 100 : 0
  inputVolume: Pipewire.defaultAudioSource && Pipewire.defaultAudioSource.ready
    ? Pipewire.defaultAudioSource.audio.volume * 100 : 0
  outputMuted: Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.ready
    ? Pipewire.defaultAudioSink.audio.muted : false
  inputMuted: Pipewire.defaultAudioSource && Pipewire.defaultAudioSource.ready
    ? Pipewire.defaultAudioSource.audio.muted : false

  function findNode(nodes, id) {
    for (const node of nodes) {
      if (String(node.id) === id) return node
    }
    return null
  }

  function setDefaultOutput(id) {
    const node = root.findNode(root.outputNodes, id)
    if (node) Pipewire.preferredDefaultAudioSink = node
  }

  function setDefaultInput(id) {
    const node = root.findNode(root.inputNodes, id)
    if (node) Pipewire.preferredDefaultAudioSource = node
  }

  function setOutputVolume(volume) {
    const node = Pipewire.defaultAudioSink
    if (node && node.ready && node.audio)
      node.audio.volume = Math.max(0, Math.min(100, volume)) / 100
  }

  function setInputVolume(volume) {
    const node = Pipewire.defaultAudioSource
    if (node && node.ready && node.audio)
      node.audio.volume = Math.max(0, Math.min(100, volume)) / 100
  }

  function toggleOutputMute() {
    const node = Pipewire.defaultAudioSink
    if (node && node.ready && node.audio) node.audio.muted = !node.audio.muted
  }

  function toggleInputMute() {
    const node = Pipewire.defaultAudioSource
    if (node && node.ready && node.audio) node.audio.muted = !node.audio.muted
  }
}
