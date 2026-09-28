import QtQuick
import qs.components.theme

Rectangle {
  id: root

  property url iconSource
  property real iconSize: 16
  property real padding: Theme.spacingSm
  property color backgroundColor: Theme.buttonBackground
  property color hoverBackgroundColor: Theme.buttonHoverBackground
  property color pressedBackgroundColor: Theme.buttonPressedBackground
  property bool hovered: mouseArea.containsMouse
  property bool pressed: mouseArea.pressed
  property string accessibleName: ""

  signal clicked()

  implicitWidth: iconSize + padding * 2
  implicitHeight: iconSize + padding * 2

  color: !enabled ? backgroundColor
    : pressed ? pressedBackgroundColor
    : hovered || activeFocus ? hoverBackgroundColor : backgroundColor
  radius: Theme.spacingMd
  opacity: enabled ? 1 : 0.5
  activeFocusOnTab: true
  Accessible.name: accessibleName
  Accessible.role: Accessible.Button

  Keys.onReturnPressed: root.clicked()
  Keys.onEnterPressed: root.clicked()
  Keys.onSpacePressed: root.clicked()

  Behavior on color {
    ColorAnimation { duration: Theme.motionFast }
  }

  Image {
    anchors.centerIn: parent
    width: root.iconSize
    height: root.iconSize
    source: root.iconSource
    sourceSize.width: root.iconSize
    sourceSize.height: root.iconSize
    fillMode: Image.PreserveAspectFit
    mipmap: true
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
