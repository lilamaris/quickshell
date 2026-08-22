import QtQuick

Rectangle {
  id: root

  property string text: "undefined"
  property color foregroundColor: "#FFFFFF"
  property color backgroundColor: "#45475a"
  property bool hovered: mouseArea.containsMouse

  signal clicked()
  signal hoverChanged(bool hovered)

  implicitWidth: text.width + 2
  implicitHeight: text.height + 0.5

  color: backgroundColor

  Text {
    id: text
    anchors.centerIn: parent

    text: root.text
    color: root.foregroundColor
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    onEntered: root.hovered = true
    onExited: root.hovered = false
    onHoveredChanged: hoverChanged(hovered)

    onClicked: {
      root.clicked();
    }
  }
}
