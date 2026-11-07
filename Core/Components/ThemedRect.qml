import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Effects
import qs.components.theme

Item {
  id: root

  property real radius: height / 2
  default property alias content: contentSlot.data

  Rectangle {
    id: shape

    anchors.fill: parent
    radius: root.radius
    color: Theme.barBackground
  }

  Item {
    id: contentSlot

    anchors.fill: parent
  }
}
