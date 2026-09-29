import QtQuick
import qs.components.theme

Rectangle {
  id: root

  property url iconSource
  property string title: ""
  property string subtitle: ""
  property string detail: ""
  property bool detailIsAction: false
  property bool selected: false
  property bool hovered: mouseArea.containsMouse
  property bool pressed: mouseArea.pressed

  signal clicked()

  implicitHeight: 54
  radius: Theme.spacingMd
  color: pressed ? Theme.buttonPressedBackground
    : selected ? Theme.accentBackground
    : hovered || activeFocus ? Theme.buttonHoverBackground : Theme.cardBackground
  opacity: enabled ? 1 : 0.5
  activeFocusOnTab: true
  Accessible.name: title + (subtitle ? ", " + subtitle : "") + (detail ? ", " + detail : "")
  Accessible.role: Accessible.Button

  Keys.onReturnPressed: root.clicked()
  Keys.onEnterPressed: root.clicked()
  Keys.onSpacePressed: root.clicked()

  Behavior on color {
    ColorAnimation { duration: Theme.motionFast }
  }

  Image {
    id: icon
    anchors.left: parent.left
    anchors.leftMargin: Theme.spacingLg
    anchors.verticalCenter: parent.verticalCenter
    width: 20
    height: 20
    source: root.iconSource
    sourceSize.width: width
    sourceSize.height: height
    fillMode: Image.PreserveAspectFit
  }

  Column {
    anchors.left: icon.right
    anchors.leftMargin: Theme.spacingLg
    anchors.right: detailLabel.left
    anchors.rightMargin: Theme.spacingMd
    anchors.verticalCenter: parent.verticalCenter
    spacing: Theme.spacingXs

    Text {
      width: parent.width
      text: root.title
      color: Theme.textPrimary
      font.pixelSize: Theme.fontSizeNormal
      font.weight: root.selected ? Font.DemiBold : Font.Normal
      elide: Text.ElideRight
    }

    Text {
      width: parent.width
      text: root.subtitle
      color: root.selected ? Theme.accent : Theme.textMuted
      font.pixelSize: Theme.fontSizeSmall
      elide: Text.ElideRight
    }
  }

  Text {
    id: detailLabel
    anchors.right: parent.right
    anchors.rightMargin: Theme.spacingLg
    anchors.verticalCenter: parent.verticalCenter
    width: root.detailIsAction ? 72 : 62
    text: root.detail
    color: root.detailIsAction ? Theme.accent : Theme.textMuted
    font.pixelSize: Theme.fontSizeSmall
    font.weight: root.detailIsAction ? Font.DemiBold : Font.Normal
    horizontalAlignment: Text.AlignRight
    elide: Text.ElideRight
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    enabled: root.enabled
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: root.clicked()
  }
}
