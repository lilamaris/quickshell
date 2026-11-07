import Quickshell
import QtQuick
import qs.components.theme

Rectangle {
  id: root

  implicitWidth: timeText.implicitWidth + 16
  implicitHeight: 28

  color: "transparent"

  SystemClock {
    id: clock
    precision: SystemClock.Seconds
  }

  Text {
    id: timeText

    anchors.centerIn: parent
    text: Qt.formatDateTime(clock.date, "yyyy. MM. dd. ddd  HH:mm:ss")
    color: Theme.barText
    font.pixelSize: Theme.fontSizeNormal
    font.weight: Font.Medium
  }

  Accessible.name: "System time: " + Qt.formatDateTime(clock.date, "yyyy-MM-dd HH:mm:ss")
  Accessible.role: Accessible.StaticText
}
