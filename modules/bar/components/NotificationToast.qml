import Quickshell
import QtQuick
import qs.components.common
import qs.services.system.notifications

PopupWindow {
  id: root

  property var anchorWindow

  color: "transparent"
  implicitWidth: 360
  implicitHeight: card.implicitHeight + 12

  anchor {
    window: root.anchorWindow
    rect.x: root.anchorWindow ? root.anchorWindow.width - root.implicitWidth - 8 : 0
    rect.y: root.anchorWindow ? root.anchorWindow.height + 8 : 0
  }

  NotificationCard {
    id: card
    x: 0
    y: 0
    width: root.implicitWidth
    notification: NotificationService.toastNotification
    onDismissed: NotificationService.toastNotification.dismiss()
  }
}
