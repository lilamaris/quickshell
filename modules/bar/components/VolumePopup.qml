import QtQuick
import QtQuick.Controls
import qs.services.system.audio

Item {
  id: root

  readonly property var audio: AudioService.backend
  property real pendingOutputVolume: 0
  property real pendingInputVolume: 0

  implicitWidth: 320
  implicitHeight: 480

  Column {
    id: content
    width: parent.width
    padding: 12
    spacing: 8

    Row {
      width: 296
      spacing: 8

      Text {
        width: 240
        text: "Audio · " + root.audio.backendName
        color: "#cdd6f4"
        font.bold: true
        elide: Text.ElideRight
      }

      Button {
        text: "↻"
        onClicked: root.audio.refresh()
      }
    }

    Text {
      visible: !root.audio.available
      width: 296
      wrapMode: Text.Wrap
      text: root.audio.error || "Audio backend is unavailable"
      color: "#f38ba8"
    }

    Text { text: "Output devices"; color: "#a6adc8"; font.bold: true }

    ListView {
      id: outputList
      width: 296
      height: 105
      clip: true
      spacing: 4
      model: root.audio.outputDevices

      delegate: Button {
        required property var modelData
        width: outputList.width
        text: (modelData.active ? "✓ " : "") + modelData.name
        enabled: root.audio.available
        onClicked: root.audio.setDefaultOutput(modelData.id)
      }
    }

    Row {
      spacing: 8
      Button {
        width: 48
        text: root.audio.outputMuted ? "Muted" : "🔊"
        enabled: root.audio.available && root.audio.defaultOutputId !== ""
        onClicked: root.audio.toggleOutputMute()
      }
      Slider {
        id: outputSlider
        width: 192
        from: 0
        to: 100
        value: 0
        enabled: root.audio.available && root.audio.defaultOutputId !== ""
        onMoved: {
          root.pendingOutputVolume = value
          outputDebounce.restart()
        }
        onPressedChanged: {
          if (pressed) {
            root.pendingOutputVolume = value
          } else {
            outputDebounce.stop()
            root.audio.setOutputVolume(root.pendingOutputVolume)
          }
        }
      }
      Text {
        anchors.verticalCenter: parent.verticalCenter
        width: 40
        text: Math.round(outputSlider.value) + "%"
        color: "white"
      }
    }

    Text { text: "Input devices"; color: "#a6adc8"; font.bold: true }

    ListView {
      id: inputList
      width: 296
      height: 105
      clip: true
      spacing: 4
      model: root.audio.inputDevices

      delegate: Button {
        required property var modelData
        width: inputList.width
        text: (modelData.active ? "✓ " : "") + modelData.name
        enabled: root.audio.available
        onClicked: root.audio.setDefaultInput(modelData.id)
      }
    }

    Row {
      spacing: 8
      Button {
        width: 48
        text: root.audio.inputMuted ? "Muted" : "🎙"
        enabled: root.audio.available && root.audio.defaultInputId !== ""
        onClicked: root.audio.toggleInputMute()
      }
      Slider {
        id: inputSlider
        width: 192
        from: 0
        to: 100
        value: 0
        enabled: root.audio.available && root.audio.defaultInputId !== ""
        onMoved: {
          root.pendingInputVolume = value
          inputDebounce.restart()
        }
        onPressedChanged: {
          if (pressed) {
            root.pendingInputVolume = value
          } else {
            inputDebounce.stop()
            root.audio.setInputVolume(root.pendingInputVolume)
          }
        }
      }
      Text {
        anchors.verticalCenter: parent.verticalCenter
        width: 40
        text: Math.round(inputSlider.value) + "%"
        color: "white"
      }
    }
  }

  Timer {
    id: outputDebounce
    interval: 120
    onTriggered: root.audio.setOutputVolume(root.pendingOutputVolume)
  }

  Timer {
    id: inputDebounce
    interval: 120
    onTriggered: root.audio.setInputVolume(root.pendingInputVolume)
  }

  Binding {
    target: outputSlider
    property: "value"
    value: root.audio.outputVolume
    when: !outputSlider.pressed
  }

  Binding {
    target: inputSlider
    property: "value"
    value: root.audio.inputVolume
    when: !inputSlider.pressed
  }
}
