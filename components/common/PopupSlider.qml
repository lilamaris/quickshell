import QtQuick
import QtQuick.Controls
import qs.components.theme

Slider {
  id: root

  from: 0
  to: 100
  implicitHeight: 32
  Accessible.role: Accessible.Slider

  background: Rectangle {
    x: root.leftPadding
    y: root.topPadding + root.availableHeight / 2 - height / 2
    width: root.availableWidth
    height: 4
    radius: 2
    color: Theme.buttonBackground

    Rectangle {
      width: root.visualPosition * parent.width
      height: parent.height
      radius: parent.radius
      color: Theme.accent
    }
  }

  handle: Rectangle {
    x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
    y: root.topPadding + root.availableHeight / 2 - height / 2
    width: 14
    height: 14
    radius: 7
    color: root.enabled ? Theme.accent : Theme.textMuted
    border.width: 2
    border.color: Theme.popupBackground
  }
}
