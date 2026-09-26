import QtQuick
import QtQuick.Controls
import qs.components.theme
import qs.services.system.audio

Item {
  id: root

  readonly property var audio: AudioService.backend

  implicitWidth: 320
  implicitHeight: 480

  Column {
    id: content
    width: parent.width
    padding: Theme.spacingLg
    spacing: Theme.spacingMd

    Text {
      width: 296
      text: "Audio · " + root.audio.backendName
      color: Theme.textHeading
      font.bold: true
      elide: Text.ElideRight
    }

    Text {
      visible: !root.audio.available
      width: 296
      wrapMode: Text.Wrap
      text: root.audio.error || "Audio backend is unavailable"
      color: Theme.textError
    }

    Text { text: "Output devices"; color: Theme.textMuted; font.bold: true }

    ListView {
      id: outputList
      width: 296
      height: 105
      clip: true
      spacing: Theme.spacingSm
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
      spacing: Theme.spacingMd
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
        onMoved: root.audio.setOutputVolume(value)
      }
      Text {
        anchors.verticalCenter: parent.verticalCenter
        width: 40
        text: Math.round(outputSlider.value) + "%"
        color: Theme.textPrimary
      }
    }

    Text { text: "Input devices"; color: Theme.textMuted; font.bold: true }

    ListView {
      id: inputList
      width: 296
      height: 105
      clip: true
      spacing: Theme.spacingSm
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
      spacing: Theme.spacingMd
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
        onMoved: root.audio.setInputVolume(value)
      }
      Text {
        anchors.verticalCenter: parent.verticalCenter
        width: 40
        text: Math.round(inputSlider.value) + "%"
        color: Theme.textPrimary
      }
    }
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
