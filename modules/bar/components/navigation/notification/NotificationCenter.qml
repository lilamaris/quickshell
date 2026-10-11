import QtQuick
import QtQuick.Controls
import qs.components.common
import qs.components.theme
import qs.services.system.notifications

Item {
  id: root

  implicitWidth: 360
  implicitHeight: content.implicitHeight

  Column {
    id: content
    width: root.implicitWidth
    padding: 16
    spacing: Theme.spacingLg

    Row {
      width: 328
      height: 32
      spacing: Theme.spacingMd

      Text {
        width: parent.width - clearButton.width - parent.spacing
        anchors.verticalCenter: parent.verticalCenter
        text: "Notifications"
        color: Theme.textHeading
        font.pixelSize: 16
        font.weight: Font.DemiBold
      }

      TextButton {
        id: clearButton
        width: 76
        text: "Clear all"
        enabled: notificationList.count > 0
        onClicked: NotificationService.clearAll()
      }
    }

    Text {
      visible: notificationList.count === 0
      width: 328
      text: "No notifications"
      color: Theme.textMuted
      font.pixelSize: Theme.fontSizeNormal
    }

    ListView {
      id: notificationList
      visible: count > 0
      width: 328
      height: Math.min(contentHeight, 320)
      clip: true
      spacing: Theme.spacingSm
      model: NotificationService.notifications
      ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

      delegate: NotificationCard {
        required property var modelData
        width: notificationList.width
        notification: modelData
        onDismissed: modelData.dismiss()
      }
    }
  }
}
