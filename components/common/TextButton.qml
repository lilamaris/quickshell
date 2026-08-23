import QtQuick

Rectangle {
  id: root

  property string text: "undefined"
  property color foregroundColor: "#FFFFFF"
  property color backgroundColor: "#45475a"
  property bool hovered: mouseArea.containsMouse

  signal clicked()

  implicitWidth: label.width + 2
  implicitHeight: label.height + 0.5

  color: backgroundColor

  Text {
    id: label
    anchors.centerIn: parent

    text: root.text
    color: root.foregroundColor
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    onClicked: root.clicked()
  }
}
