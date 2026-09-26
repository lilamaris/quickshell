import QtQuick
import qs.components.theme

Rectangle {
  id: root

  property url iconSource
  property real iconSize: 16
  property real padding: Theme.spacingSm
  property color backgroundColor: Theme.buttonBackground
  property bool hovered: mouseArea.containsMouse
  property string accessibleName: ""

  signal clicked()

  implicitWidth: iconSize + padding * 2
  implicitHeight: iconSize + padding * 2

  color: backgroundColor
  radius: Theme.spacingMd
  opacity: enabled ? 1 : 0.5
  Accessible.name: accessibleName
  Accessible.role: Accessible.Button

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
