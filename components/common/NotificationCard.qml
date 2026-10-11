import QtQuick
import qs.components.theme

Rectangle {
  id: root

  required property var notification
  signal dismissed()

  implicitHeight: Math.max(72, details.implicitHeight + 20)
  radius: Theme.spacingMd
  color: Theme.cardBackground

  Column {
    id: details
    anchors.left: parent.left
    anchors.leftMargin: Theme.spacingLg
    anchors.right: dismissButton.left
    anchors.rightMargin: Theme.spacingMd
    anchors.verticalCenter: parent.verticalCenter
    spacing: Theme.spacingXs

    Text {
      width: parent.width
      text: root.notification ? root.notification.appName : ""
      color: Theme.textMuted
      font.pixelSize: Theme.fontSizeSmall
      elide: Text.ElideRight
      textFormat: Text.PlainText
    }

    Text {
      width: parent.width
      text: root.notification ? root.notification.summary : ""
      color: Theme.textPrimary
      font.pixelSize: Theme.fontSizeNormal
      font.weight: Font.DemiBold
      wrapMode: Text.Wrap
      maximumLineCount: 2
      elide: Text.ElideRight
      textFormat: Text.PlainText
    }

    Text {
      visible: text !== ""
      width: parent.width
      text: root.notification ? root.notification.body : ""
      color: Theme.textMuted
      font.pixelSize: Theme.fontSizeSmall
      wrapMode: Text.Wrap
      maximumLineCount: 3
      elide: Text.ElideRight
      textFormat: Text.PlainText
    }
  }

  TextButton {
    id: dismissButton
    anchors.right: parent.right
    anchors.rightMargin: Theme.spacingMd
    anchors.verticalCenter: parent.verticalCenter
    width: 64
    implicitHeight: 28
    text: "Close"
    onClicked: root.dismissed()
  }
}
