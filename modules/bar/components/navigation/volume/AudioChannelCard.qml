import QtQuick
import qs.components.common
import qs.components.theme

Rectangle {
  id: root

  property string channelName: ""
  property string deviceName: ""
  property url iconSource
  property url mutedIconSource
  property real volume: 0
  property bool muted: false

  signal volumeMoved(real value)
  signal muteClicked()

  implicitWidth: 288
  implicitHeight: 86
  radius: Theme.popupRadius
  color: Theme.cardBackground
  opacity: enabled ? 1 : 0.5

  Image {
    id: channelIcon
    anchors.left: parent.left
    anchors.leftMargin: Theme.spacingLg
    anchors.top: parent.top
    anchors.topMargin: Theme.spacingLg
    width: 20
    height: 20
    source: root.muted ? root.mutedIconSource : root.iconSource
    sourceSize.width: width
    sourceSize.height: height
  }

  Column {
    anchors.left: channelIcon.right
    anchors.leftMargin: Theme.spacingLg
    anchors.right: parent.right
    anchors.rightMargin: Theme.spacingLg
    anchors.top: parent.top
    anchors.topMargin: Theme.spacingMd
    spacing: Theme.spacingXs

    Text {
      width: parent.width
      text: root.deviceName || "No " + root.channelName.toLowerCase() + " device"
      color: Theme.textPrimary
      font.pixelSize: Theme.fontSizeNormal
      font.weight: Font.DemiBold
      elide: Text.ElideRight
    }

    Text {
      width: parent.width
      text: root.channelName + (!root.enabled ? " · Unavailable"
        : root.muted ? " · Muted" : " · Active")
      color: !root.enabled || root.muted ? Theme.textMuted : Theme.textSuccess
      font.pixelSize: Theme.fontSizeSmall
    }
  }

  Row {
    anchors.left: parent.left
    anchors.leftMargin: Theme.spacingLg
    anchors.right: parent.right
    anchors.rightMargin: Theme.spacingLg
    anchors.bottom: parent.bottom
    anchors.bottomMargin: Theme.spacingMd
    height: 32
    spacing: Theme.spacingMd

    IconButton {
      id: muteButton
      iconSource: root.muted ? root.mutedIconSource : root.iconSource
      iconSize: 16
      padding: 8
      accessibleName: (root.muted ? "Unmute " : "Mute ") + root.channelName.toLowerCase()
      enabled: root.enabled
      onClicked: root.muteClicked()
    }

    PopupSlider {
      id: volumeSlider
      width: parent.width - muteButton.width - volumeLabel.width - parent.spacing * 2
      enabled: root.enabled
      Accessible.name: root.channelName + " volume"
      onMoved: root.volumeMoved(value)
    }

    Text {
      id: volumeLabel
      anchors.verticalCenter: parent.verticalCenter
      width: 36
      text: Math.round(volumeSlider.value) + "%"
      color: Theme.textPrimary
      font.pixelSize: Theme.fontSizeSmall
      horizontalAlignment: Text.AlignRight
    }
  }

  Binding {
    target: volumeSlider
    property: "value"
    value: root.volume
    when: !volumeSlider.pressed
  }
}
