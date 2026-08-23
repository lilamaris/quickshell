import QtQuick

Rectangle {
  id: root

  property url iconSource
  property real iconSize: 16
  property real padding: 4
  property color backgroundColor: "#45475a"
  property bool hovered: mouseArea.containsMouse
  property string accessibleName: ""

  signal clicked()

  implicitWidth: iconSize + padding * 2
  implicitHeight: iconSize + padding * 2

  color: backgroundColor
  opacity: enabled ? 1 : 0.5
  Accessible.name: accessibleName
  Accessible.role: Accessible.Button

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
