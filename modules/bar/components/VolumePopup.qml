import QtQuick
import QtQuick.Controls
import qs.components.common
import qs.components.theme
import qs.services.system.audio

Item {
  id: root

  readonly property Audio audio: AudioService.backend
  readonly property var activeOutput: audio.outputDevices.find(device => device.active)
  readonly property var activeInput: audio.inputDevices.find(device => device.active)

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

      Text {
        width: parent.width - backendLabel.width
        anchors.verticalCenter: parent.verticalCenter
        text: "Audio"
        color: Theme.textHeading
        font.pixelSize: 16
        font.weight: Font.DemiBold
      }

      Text {
        id: backendLabel
        anchors.verticalCenter: parent.verticalCenter
        text: root.audio.backendName
        color: Theme.textMuted
        font.pixelSize: Theme.fontSizeSmall
      }
    }

    Rectangle {
      visible: !root.audio.available
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
        text: root.audio.error || "Audio backend is unavailable"
        color: Theme.textError
        font.pixelSize: Theme.fontSizeSmall
        wrapMode: Text.Wrap
      }
    }

    AudioChannelCard {
      width: 288
      visible: root.audio.available
      enabled: root.audio.defaultOutputId !== ""
      channelName: "Output"
      deviceName: root.activeOutput ? root.activeOutput.name : ""
      iconSource: Qt.resolvedUrl("../../../assets/icons/audio-volume-high.svg")
      mutedIconSource: Qt.resolvedUrl("../../../assets/icons/audio-volume-muted.svg")
      volume: root.audio.outputVolume
      muted: root.audio.outputMuted
      onVolumeMoved: value => root.audio.setOutputVolume(value)
      onMuteClicked: root.audio.toggleOutputMute()
    }

    Row {
      visible: root.audio.available
      width: 288
      height: 16

      Text {
        width: parent.width - outputCount.width
        text: "Output devices"
        color: Theme.textMuted
        font.pixelSize: Theme.fontSizeSmall
        font.weight: Font.DemiBold
      }

      Text {
        id: outputCount
        text: String(outputList.count)
        color: Theme.textMuted
        font.pixelSize: Theme.fontSizeSmall
      }
    }

    Text {
      visible: root.audio.available && outputList.count === 0
      width: 288
      text: "No output devices found"
      color: Theme.textMuted
      font.pixelSize: Theme.fontSizeNormal
    }

    ListView {
      id: outputList
      visible: root.audio.available && count > 0
      width: 288
      height: Math.min(count * 54 + Math.max(0, count - 1) * spacing, 58)
      clip: true
      spacing: Theme.spacingSm
      model: root.audio.outputDevices
      ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

      delegate: PopupListItem {
        required property var modelData
        width: outputList.width
        iconSource: Qt.resolvedUrl("../../../assets/icons/audio-volume-high.svg")
        title: modelData.name
        subtitle: modelData.active ? "Default output" : "Select as output"
        detail: modelData.active ? "Current" : ""
        selected: modelData.active
        enabled: root.audio.available
        onClicked: root.audio.setDefaultOutput(modelData.id)
      }
    }

    AudioChannelCard {
      width: 288
      visible: root.audio.available
      enabled: root.audio.defaultInputId !== ""
      channelName: "Input"
      deviceName: root.activeInput ? root.activeInput.name : ""
      iconSource: Qt.resolvedUrl("../../../assets/icons/audio-input.svg")
      mutedIconSource: Qt.resolvedUrl("../../../assets/icons/audio-input-muted.svg")
      volume: root.audio.inputVolume
      muted: root.audio.inputMuted
      onVolumeMoved: value => root.audio.setInputVolume(value)
      onMuteClicked: root.audio.toggleInputMute()
    }

    Row {
      visible: root.audio.available
      width: 288
      height: 16

      Text {
        width: parent.width - inputCount.width
        text: "Input devices"
        color: Theme.textMuted
        font.pixelSize: Theme.fontSizeSmall
        font.weight: Font.DemiBold
      }

      Text {
        id: inputCount
        text: String(inputList.count)
        color: Theme.textMuted
        font.pixelSize: Theme.fontSizeSmall
      }
    }

    Text {
      visible: root.audio.available && inputList.count === 0
      width: 288
      text: "No input devices found"
      color: Theme.textMuted
      font.pixelSize: Theme.fontSizeNormal
    }

    ListView {
      id: inputList
      visible: root.audio.available && count > 0
      width: 288
      height: Math.min(count * 54 + Math.max(0, count - 1) * spacing, 58)
      clip: true
      spacing: Theme.spacingSm
      model: root.audio.inputDevices
      ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

      delegate: PopupListItem {
        required property var modelData
        width: inputList.width
        iconSource: Qt.resolvedUrl("../../../assets/icons/audio-input.svg")
        title: modelData.name
        subtitle: modelData.active ? "Default input" : "Select as input"
        detail: modelData.active ? "Current" : ""
        selected: modelData.active
        enabled: root.audio.available
        onClicked: root.audio.setDefaultInput(modelData.id)
      }
    }
  }
}
