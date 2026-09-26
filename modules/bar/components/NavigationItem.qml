import QtQuick

Item {
  property Component indicator
  property Component content
  readonly property bool indicatorHovered: indicatorLoader.item
    ? indicatorLoader.item.hovered : false

  implicitWidth: indicatorLoader.item ? indicatorLoader.item.implicitWidth : 0
  implicitHeight: indicatorLoader.item ? indicatorLoader.item.implicitHeight : 0

  Loader {
    id: indicatorLoader
    sourceComponent: indicator
  }
}
