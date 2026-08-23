import QtQuick

Item {
  property Component indicator
  property Component content

  implicitWidth: indicatorLoader.item?.implicitWidth ?? 0
  implicitHeight: indicatorLoader.item?.implicitHeight ?? 0

  Loader {
    id: indicatorLoader
    sourceComponent: indicator
  }
}
