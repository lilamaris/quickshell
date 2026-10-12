import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

pragma Singleton

Singleton {
  id: root

  readonly property var outputs: getAllOutputs()
  readonly property var inputs: getAllInputs()

  property PwNode defaultOutput: Pipewire.defaultAudioSink
  property bool outputReady: !!isAudioReady(defaultOutput)
  property int outputVolume: outputReady ? defaultOutput.audio.volume * 100 : 0
  property bool outputMuted: outputReady ? defaultOutput.audio.muted : false

  property PwNode defaultInput: Pipewire.defaultAudioSource
  property bool inputReady: !!isAudioReady(defaultInput)
  property int inputVolume: inputReady ? defaultInput.audio.volume * 100 : 0
  property bool inputMuted: inputReady ? defaultInput.audio.muted : false

  property PwObjectTracker tracker: PwObjectTracker {
    objects: root.outputs.concat(root.inputs)
  }

  function getAllOutputs() {
    return Pipewire.nodes.values.filter(node =>
      isOutput(node) && !node.isStream
    )
  }

  function getAllInputs() {
    return Pipewire.nodes.values.filter(node =>
      isInput(node) && !node.isStream
    )
  }

  function isOutput(node) {
    return node && node.audio && node.isSink
  }

  function isInput(node) {
    return node && node.audio && !node.isSink
  }

  function isAudioReady(node) {
    return node && node.audio && node.ready
  }

  function setDefaultOutput(node) {
    if (isOutput(node)) Pipewire.preferredDefaultAudioSink = node
  }

  function setDefaultInput(node) {
    if (isInput(node)) Pipewire.preferredDefaultAudioSource = node
  }

  function setOutputVolume(volume) {
    if (isAudioReady(defaultOutput))
    defaultOutput.audio.volume = Math.max(0, Math.min(100, volume)) / 100
  }

  function setInputVolume(volume) {
    if (isAudioReady(defaultInput))
    defaultInput.audio.volume = Math.max(0, Math.min(100, volume)) / 100
  }

  function setOutputMute(muted) {
    if (isAudioReady(defaultOutput))
    defaultOutput.audio.muted = muted
  }

  function setInputMuted(muted) {
    if (isAudioReady(defaultInput))
    defaultInput.audio.muted = muted
  }

  function toggleOutputMute() {
    setOutputMute(!outputMuted)
  }

  function toggleInputMute() {
    setInputMute(!inputMuted)
  }
}
