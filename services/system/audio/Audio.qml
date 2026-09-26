import QtQuick

QtObject {
  property bool available: false
  property string backendName: "Unavailable"
  property var outputDevices: []
  property var inputDevices: []
  property string defaultOutputId: ""
  property string defaultInputId: ""
  property real outputVolume: 0
  property real inputVolume: 0
  property bool outputMuted: false
  property bool inputMuted: false
  property string error: ""

  function setDefaultOutput(id) {}
  function setDefaultInput(id) {}
  function setOutputVolume(volume) {}
  function setInputVolume(volume) {}
  function toggleOutputMute() {}
  function toggleInputMute() {}
}
