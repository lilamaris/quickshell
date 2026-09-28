import QtQuick
import qs.components.theme

Rectangle {
  id: root

  property string text: ""
  property color foregroundColor: emphasized ? Theme.popupBackground : Theme.textPrimary
  property color backgroundColor: emphasized ? Theme.accent : Theme.buttonBackground
  property bool emphasized: false
  property bool hovered: mouseArea.containsMouse
  property bool pressed: mouseArea.pressed

  signal clicked()

  implicitWidth: label.implicitWidth + Theme.spacingLg * 2
  implicitHeight: 32

  radius: Theme.spacingMd
  color: !enabled ? backgroundColor
    : pressed ? (emphasized ? Qt.darker(backgroundColor, 1.25) : Theme.buttonPressedBackground)
    : hovered || activeFocus
      ? (emphasized ? Qt.lighter(backgroundColor, 1.12) : Theme.buttonHoverBackground)
      : backgroundColor
  opacity: enabled ? 1 : 0.5
  activeFocusOnTab: true
  Accessible.name: text
  Accessible.role: Accessible.Button

  Keys.onReturnPressed: root.clicked()
  Keys.onEnterPressed: root.clicked()
  Keys.onSpacePressed: root.clicked()

  Behavior on color {
    ColorAnimation { duration: Theme.motionFast }
  }

  Text {
    id: label
    anchors.centerIn: parent
    width: Math.max(0, root.width - Theme.spacingLg * 2)
    text: root.text
    color: root.foregroundColor
    font.pixelSize: Theme.fontSizeNormal
    font.weight: Font.DemiBold
    horizontalAlignment: Text.AlignHCenter
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
